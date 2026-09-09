#!/usr/bin/env zsh
emulate -LR zsh
setopt err_exit no_unset
command python3 - "${0:A:h:h}" <<'PY'
import hashlib
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import tempfile

os.umask(0o077)
repo = Path(sys.argv[1])
base = '331d111d683ee29f735858c7fe2fd7389890d30c'
archive = subprocess.check_output(['git', '-C', str(repo), 'archive', base])
count = 0
with tempfile.TemporaryDirectory(prefix='installer-test-', dir=repo.parent) as work:
    work = Path(work)
    def fixture():
        global count
        count += 1
        home = work / str(count)
        root = home / '.local/share/zsh-public'
        root.mkdir(parents=True)
        with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
            for member in tar.getmembers():
                assert not member.name.startswith('/') and '..' not in Path(member.name).parts
                assert member.isdir() or member.isfile()
            tar.extractall(root, filter='data')
        for p in root.rglob('*'):
            p.chmod(0o755 if p.is_dir() or p.stat().st_mode & 0o111 else 0o644)
        shutil.copyfile(repo / 'install-uberspace.zsh', root / 'install-uberspace.zsh')
        files = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in root.rglob('*') if p.is_file()}
        (root / '.release-manifest.json').write_text(json.dumps({'version': 1, 'revision': base, 'files': files}))
        (root / '.release-owner').write_text('zsh-public-v1\n')
        bindir = home / 'bin'
        bindir.mkdir()
        (home / 'shell').write_text('/bin/sh')
        (bindir / 'getent').write_text('''#!/usr/bin/python3
import os
from pathlib import Path
h = Path(os.environ['HOME'])
print('fixture:x:' + str(os.getuid()) + ':1::' + str(h) + ':' + (h / 'shell').read_text())
''')
        (bindir / 'chsh').write_text('''#!/usr/bin/python3
import os, sys
from pathlib import Path
h = Path(os.environ['HOME'])
if (h / 'fail-chsh').exists(): sys.exit(1)
(h / 'shell').write_text(sys.argv[2])
''')
        (bindir / 'uberspace').write_text('#!/bin/sh\nexit 0\n')
        for p in bindir.iterdir():
            p.chmod(0o700)
        env = {'HOME': str(home), 'PATH': str(bindir) + ':/usr/bin:/bin', 'LC_ALL': 'C'}
        def run(action='', ok=True):
            p = subprocess.run(['/usr/bin/zsh', '-f', str(root / 'install-uberspace.zsh')] + ([action] if action else []),
                               env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if (p.returncode == 0) != ok:
                # Never emit child output or environment; fixture number is sufficient.
                raise AssertionError('fixture %d unexpected status for %s: %d' % (count, action, p.returncode))
            assert not p.stderr
            assert str(home).encode() not in p.stdout
            return p.stdout
        return home, root, run, env

    h, r, run, env = fixture()
    assert b'preview ok' in run()
    run('--check')
    assert not (h / '.zshrc').exists() and not (r / '.install-lock').exists()
    assert b'pending' in run('--apply')
    assert (h / '.zshrc').is_symlink()
    run('--apply', False)
    assert b'rollback ok' in run('--rollback')
    assert not (h / '.zshrc').is_symlink() and (h / 'shell').read_text() == '/bin/sh'
    run('--apply')
    run('--finalize')
    assert not (r / '.install-transaction.json').exists()
    run('--apply')
    run('--rollback')
    assert (h / '.zshrc').is_symlink()  # preexisting correct links are not ours to remove

    for target in ('.zshrc', '.zprofile', '.zlogout', '.zshenv', '.zlogin'):
        for dangling in (False, True):
            h, r, run, env = fixture()
            if dangling:
                (h / target).symlink_to(h / 'absent')
            else:
                (h / target).write_text('protected')
            run('--check', False)
            run('--apply', False)
            assert (h / target).is_symlink() if dangling else (h / target).read_text() == 'protected'
            assert not (r / '.install-transaction.json').exists()
    # R5: early_startup_sentinel_blocked_by_zsh_f
    h, r, run, env = fixture()
    startup = 'print sentinel > "$HOME/startup-sentinel"\n'
    (h / '.zshenv').write_text(startup)
    for action in ('', '--check', '--apply'):
        assert run(action, False) == b'installer blocked\n'
        assert not (h / 'startup-sentinel').exists()
        assert (h / '.zshenv').read_text() == startup
        assert not (h / '.zshrc').exists()
        assert not (r / '.install-transaction.json').exists()
        assert not (r / '.install-lock').exists()
    h, r, run, env = fixture()
    env['ZDOTDIR'] = str(h / 'elsewhere')
    run('--apply', False)
    h, r, run, env = fixture()
    (r / 'zshrc').write_text('changed')
    run('--apply', False)
    h, r, run, env = fixture()
    (r / '.install-lock').mkdir()
    run('--apply', False)
    h, r, run, env = fixture()
    (h / 'fail-chsh').touch()
    assert b'rolled-back' in run('--apply', False)
    assert not (h / '.zshrc').is_symlink()
    h, r, run, env = fixture()
    run('--apply')
    (h / 'fail-chsh').touch()
    assert b'recovery-required' in run('--rollback', False)
    assert (h / '.zshrc').is_symlink()
    h, r, run, env = fixture()
    run('--apply')
    (h / '.zprofile').unlink()
    (h / '.zprofile').write_text('protected')
    run('--rollback', False)
    assert (h / '.zprofile').read_text() == 'protected'
    assert (h / '.zshrc').is_symlink()
    h, r, run, env = fixture()
    run('--apply')
    (r / '.install-transaction.json').chmod(0o644)
    run('--rollback', False)
    h, r, run, env = fixture()
    manifest = json.loads((r / '.release-manifest.json').read_text())
    manifest['files']['../escape'] = '0' * 64
    (r / '.release-manifest.json').write_text(json.dumps(manifest))
    run('--apply', False)
    h, r, run, env = fixture()
    (h / 'bin/uberspace').unlink()
    run('--apply', False)
    h, r, run, env = fixture()
    (h / 'shell').write_text('/not-an-allowed-shell')
    run('--apply', False)
    h, r, run, env = fixture()
    (r / 'unmanifested').touch()
    run('--apply', False)
    h, r, run, env = fixture()
    env['PATH'] = str(h / 'bin')
    run('--apply', False)  # Python prerequisite missing
    h, r, run, env = fixture()
    # missing_path_zsh_is_rejected_even_when_python_is_available
    (h / 'bin/python3').symlink_to('/usr/bin/python3')
    env['PATH'] = str(h / 'bin')
    run('--apply', False)
    assert not (h / '.zshrc').exists()
    h, r, run, env = fixture()
    # allowed_zsh_alias_is_selected_by_executable_identity
    (h / 'bin/zsh').symlink_to('/usr/bin/zsh')
    run('--apply')
    allowed_zsh = [line.strip() for line in Path('/etc/shells').read_text().splitlines()
                   if line.startswith('/') and Path(line.strip()).name == 'zsh'
                   and os.access(line.strip(), os.X_OK)
                   and os.path.samefile(line.strip(), '/usr/bin/zsh')]
    chosen = (h / 'shell').read_text()
    assert chosen in allowed_zsh and chosen != str(h / 'bin/zsh')
    if '/bin/zsh' in allowed_zsh:
        assert chosen == '/bin/zsh'
    receipt = json.loads((r / '.install-transaction.json').read_text())
    assert receipt['new_shell'] == chosen
    run('--finalize')
    h, r, run, env = fixture()
    # unrelated_zsh_named_executable_is_rejected
    (h / 'bin/zsh').write_text('#!/bin/sh\nexit 0\n')
    (h / 'bin/zsh').chmod(0o700)
    run('--apply', False)
    assert (h / 'shell').read_text() == '/bin/sh' and not (h / '.zshrc').exists()
    h, r, run, env = fixture()
    (r / 'zshrc').write_text('print startup-noise\n')
    manifest = json.loads((r / '.release-manifest.json').read_text())
    manifest['files']['zshrc'] = hashlib.sha256((r / 'zshrc').read_bytes()).hexdigest()
    (r / '.release-manifest.json').write_text(json.dumps(manifest))
    run('--apply', False)  # valid manifest does not imply valid/silent startup
    assert not (h / '.zshrc').exists() and (h / 'shell').read_text() == '/bin/sh'
    h, r, run, env = fixture()
    (r / '.install-transaction.json').symlink_to(h / 'protected')
    (h / 'protected').write_text('protected')
    run('--rollback', False)
    assert (h / 'protected').read_text() == 'protected'
    h, r, run, env = fixture()
    run('--apply')
    (h / 'shell').write_text('/bin/bash')
    run('--rollback', False)
    assert (h / 'shell').read_text() == '/bin/bash' and (h / '.zshrc').is_symlink()
    h, r, run, env = fixture()
    os.link(r / 'zshrc', h / 'linked')
    run('--apply', False)
    h, r, run, env = fixture()
    (r / 'zprofile').chmod(0o666)
    run('--apply', False)
    # R4: same_revision_root_exchange_before_lock_is_blocked
    h, r, run, env = fixture()
    original_generation = (r.stat().st_dev, r.stat().st_ino)
    (h / 'bin/chsh').write_text('#!/bin/sh\n: > "$HOME/chsh-called"\nexit 1\n')
    code = (r / 'install-uberspace.zsh').read_text().split("<<'PY'\n", 1)[1].rsplit('\nPY', 1)[0]
    barrier = r"""
import os
from pathlib import Path
import shutil
import sys
root = Path(sys.argv[1])
saved_mkdir = os.mkdir
exchanged = False
def exchange_before_lock(path, mode=0o777, *, dir_fd=None):
    global exchanged
    if not exchanged and Path(path) == root / '.install-lock':
        exchanged = True
        saved_mkdir(root / '.install-lock', 0o700)
        backup = root.with_name('zsh-public-before-exchange')
        root.rename(backup)
        shutil.copytree(backup, root, ignore=shutil.ignore_patterns('.install-lock'))
    return saved_mkdir(path, mode, dir_fd=dir_fd)
os.mkdir = exchange_before_lock
exec(compile(sys.stdin.read(), '<installer>', 'exec'))
"""
    result = subprocess.run(['/usr/bin/python3', '-c', barrier, str(r), '--apply'],
                            input=code.encode(), env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert result.returncode == 1 and result.stdout == b'installer blocked\n' and not result.stderr
    assert (r.stat().st_dev, r.stat().st_ino) != original_generation
    backup = r.with_name('zsh-public-before-exchange')
    assert (backup.stat().st_dev, backup.stat().st_ino) == original_generation
    assert (backup / '.install-lock').is_dir()  # the wrapper's old-generation guard stays owned
    assert not (r / '.install-lock').exists()
    for directory in (r, backup):
        assert not (directory / '.install-transaction.json').exists()
    assert not (h / 'chsh-called').exists() and (h / 'shell').read_text() == '/bin/sh'
    assert all(not os.path.lexists(h / ('.' + n)) for n in ('zshrc', 'zprofile', 'zlogout'))
    h, r, run, env = fixture()
    run('--unknown', False)
print('installer tests: %d fixtures passed (public baseline, isolated local stubs)' % count)
PY
