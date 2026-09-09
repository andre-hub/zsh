#!/usr/bin/env zsh
# Run with zsh -f ./install-uberspace.zsh [--check|--apply|--rollback|--finalize].
# Account-local activation of a verified public release; no downloads or profile edits.
emulate -LR zsh
(( $+commands[python3] )) || { print 'installer prerequisites blocked'; exit 1; }
command python3 - "${0:A:h}" "$@" <<'PY'
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import sys
import tempfile

class Blocked(Exception):
    pass

def require(ok):
    if not ok:
        raise Blocked()

def unique_object(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result)
        result[key] = value
    return result

def regular(path, mode=None):
    st = path.lstat()
    require(stat.S_ISREG(st.st_mode) and st.st_uid == os.getuid())
    require(st.st_nlink == 1 and not st.st_mode & 0o022)
    if mode is not None:
        require(stat.S_IMODE(st.st_mode) == mode)
    return path.read_bytes()

def directory(path):
    st = path.lstat()
    require(stat.S_ISDIR(st.st_mode) and st.st_uid == os.getuid())
    require(not st.st_mode & 0o022)

def run(args, env=None):
    result = subprocess.run(args, input=b'', stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, env=env, timeout=45)
    require(result.returncode == 0)
    return result.stdout, result.stderr

def account_shell():
    out, _ = run(['getent', 'passwd', str(os.getuid())])
    rows = out.decode().splitlines()
    require(len(rows) == 1)
    fields = rows[0].split(':')
    require(len(fields) == 7 and fields[2] == str(os.getuid()))
    require(Path(fields[5]) == home)
    require(fields[6] in allowed and os.access(fields[6], os.X_OK))
    return fields[6]

def links_ok():
    for name in names:
        path = home / ('.' + name)
        if path.is_symlink():
            require(os.readlink(path) == str(root / name))
        else:
            require(not path.exists())
    # Unmanaged early/later startup hooks can redirect loading or execute arbitrary code.
    for name in ('.zshenv', '.zlogin'):
        require(not os.path.lexists(home / name))

def integrity():
    require(regular(root / '.release-owner') == b'zsh-public-v1\n')
    manifest = json.loads(regular(root / '.release-manifest.json'), object_pairs_hook=unique_object)
    require(set(manifest) == {'version', 'revision', 'files'} and type(manifest['version']) is int and manifest['version'] == 1)
    require(isinstance(manifest['revision'], str) and re.fullmatch('[0-9a-f]{40}', manifest['revision']))
    files = manifest['files']
    require(isinstance(files, dict) and all(n in files for n in (*names, 'create-links.sh', 'install-uberspace.zsh')))
    excluded = {'.release-owner', '.release-manifest.json', receipt.name}
    for name, digest in files.items():
        require(isinstance(name, str) and name and '\\' not in name)
        p = PurePosixPath(name)
        require(not p.is_absolute() and all(x not in ('', '.', '..', '.git') for x in name.split('/')))
        require(name not in excluded and p.parts[0] != lock.name)
        require(isinstance(digest, str) and re.fullmatch('[0-9a-f]{64}', digest))
        parent = root
        for part in p.parts[:-1]:
            parent /= part
            directory(parent)
        require(hashlib.sha256(regular(root / name)).hexdigest() == digest)
    for base, dirs, entries in os.walk(root, followlinks=False):
        for name in dirs[:]:
            path = Path(base) / name
            directory(path)
            if path == lock:
                dirs.remove(name)
            else:
                relative = str(path.relative_to(root))
                require(name != '.git' and any(n.startswith(relative + '/') for n in files))
        for name in entries:
            relative = str((Path(base) / name).relative_to(root))
            require(relative in files or relative in excluded)
    return manifest['revision']

def read_receipt():
    data = json.loads(regular(receipt, 0o600), object_pairs_hook=unique_object)
    require(set(data) == {'version', 'phase', 'old_shell', 'new_shell', 'created', 'revision'})
    require(type(data['version']) is int and data['version'] == 1 and data['phase'] in ('prepared', 'pending'))
    require(data['old_shell'] in allowed and data['new_shell'] in allowed)
    require(Path(data['new_shell']).name == 'zsh')
    require(isinstance(data['created'], list) and len(set(data['created'])) == len(data['created']))
    require(all(n in names for n in data['created']))
    require(isinstance(data['revision'], str) and re.fullmatch('[0-9a-f]{40}', data['revision']))
    return data

def save(data, initial=False):
    if initial:
        fd = os.open(receipt, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
        with os.fdopen(fd, 'w') as stream:
            json.dump(data, stream)
            stream.flush()
            os.fsync(stream.fileno())
    else:
        temporary = lock / 'receipt'
        with temporary.open('x') as stream:
            os.chmod(temporary, 0o600)
            json.dump(data, stream)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, receipt)

def rollback(data):
    current = account_shell()
    require(current in (data['old_shell'], data['new_shell']))
    if current != data['old_shell']:
        run(['chsh', '--shell', data['old_shell']])
        require(account_shell() == data['old_shell'])
    # Verify every owned link before deleting any, so concurrent edits stay untouched.
    for name in data['created']:
        path = home / ('.' + name)
        require(not os.path.lexists(path) or (path.is_symlink() and os.readlink(path) == str(root / name)))
    for name in data['created']:
        path = home / ('.' + name)
        if path.is_symlink():
            path.unlink()
    receipt.unlink()

def load_test(shell):
    with tempfile.TemporaryDirectory(prefix='probe-', dir=lock) as tmp:
        probe = Path(tmp)
        for name in names:
            (probe / ('.' + name)).symlink_to(root / name)
        environment = {'HOME': tmp, 'ZDOTDIR': tmp, 'PATH': os.environ.get('PATH', '/usr/bin:/bin'),
                       'TERM': 'dumb', 'SHELL': shell, 'LC_ALL': 'C', 'ZSH_INSTALL_EXPECT_ROOT': str(root)}
        # No inherited SSH state, private switches, user history, or startup hooks.
        out, err = run([shell, '-lic', '[[ ${ZSH_PUBLIC_ROOT:-} == $ZSH_INSTALL_EXPECT_ROOT && $ZDOTDIR == $HOME ]] && (( $+commands[uberspace] )) || exit 1'], environment)
        require(not out and not err)
        out, err = run([shell, '-c', ':'], environment)
        require(not out and not err)

def main():
    global home, root, names, allowed, receipt, lock
    args = sys.argv[2:]
    if len(args) > 1 or (args and args[0] not in ('--check', '--apply', '--rollback', '--finalize')):
        print('installer arguments invalid')
        return 2
    action = args[0] if args else 'preview'
    home = Path(os.environ.get('HOME', ''))
    require(home.is_absolute() and home == home.resolve())
    root = Path(sys.argv[1])
    require(root == home / '.local/share/zsh-public' and root == root.resolve())
    for path in (home, home / '.local', home / '.local/share', root):
        directory(path)
    root_stat = root.lstat()
    root_generation = (root_stat.st_dev, root_stat.st_ino)
    require(not os.environ.get('ZDOTDIR') or Path(os.environ['ZDOTDIR']) == home)
    names = ('zshrc', 'zprofile', 'zlogout')
    receipt, lock = root / '.install-transaction.json', root / '.install-lock'
    allowed = [line.strip() for line in Path('/etc/shells').read_text().splitlines()
               if line.startswith('/')]
    require(os.access(home, os.W_OK | os.X_OK) and os.access(root, os.W_OK | os.X_OK))
    if action in ('preview', '--check', '--apply'):
        require(not os.path.lexists(receipt) and not os.path.lexists(lock))
        revision = integrity()
        path_shell = shutil.which('zsh')
        require(path_shell is not None)
        # Uberspace can expose /usr/bin/zsh while only its /bin alias is allowed.
        candidates = sorted(allowed, key=lambda candidate: candidate != '/bin/zsh')
        shell = next((candidate for candidate in candidates
                      if Path(candidate).name == 'zsh' and os.access(candidate, os.X_OK)
                      and os.path.samefile(candidate, path_shell)), None)
        require(shell is not None)
        old = account_shell()
        require(shutil.which('chsh') and shutil.which('uberspace'))
        links_ok()
        if action != '--apply':
            print('installer ' + ('preview' if action == 'preview' else 'check') + ' ok')
            return 0
    os.mkdir(lock, 0o700)
    data = None
    try:
        # A wrapper may have exchanged the release after our read-only preflight.
        directory(root)
        root_stat = root.lstat()
        require((root_stat.st_dev, root_stat.st_ino) == root_generation)
        if action == '--apply':
            # Recheck after obtaining the exclusive lock.
            require(not os.path.lexists(receipt))
            integrity()
            links_ok()
            require(account_shell() == old)
            load_test(shell)
            data = {'version': 1, 'phase': 'prepared', 'old_shell': old, 'new_shell': shell,
                    'created': [n for n in names if not os.path.lexists(home / ('.' + n))], 'revision': revision}
            save(data, initial=True)
            run([shell, str(root / 'create-links.sh'), '--apply'],
                dict(os.environ, ZDOTDIR=str(home)))
            links_ok()
            require(all((home / ('.' + n)).is_symlink() for n in names))
            if old != shell:
                run(['chsh', '--shell', shell])
            require(account_shell() == shell)
            data['phase'] = 'pending'
            save(data)
            print('installer apply pending')
        elif action == '--rollback':
            data = read_receipt()
            rollback(data)
            print('installer rollback ok')
        elif action == '--finalize':
            data = read_receipt()
            require(data['phase'] == 'pending' and integrity() == data['revision'])
            require(account_shell() == data['new_shell'])
            links_ok()
            require(all((home / ('.' + n)).is_symlink() for n in names))
            receipt.unlink()
            print('installer finalize ok')
        return 0
    except Exception:
        if action == '--apply' and data is not None:
            try:
                rollback(read_receipt())
                print('installer apply rolled-back')
            except Exception:
                print('installer recovery-required')
        else:
            print('installer recovery-required' if action in ('--rollback', '--finalize') else 'installer blocked')
        return 1
    finally:
        # Only remove this invocation's empty lock; interruption retains recovery evidence.
        lock.rmdir()

try:
    sys.exit(main())
except Exception:
    print('installer blocked')
    sys.exit(1)
PY
