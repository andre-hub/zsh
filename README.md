# zsh

Small, self-contained settings for Debian/Ubuntu, Arch Linux, FreeBSD, macOS
and Cygwin, including servers and WSL. Requires zsh and Python 3 for installation; helpers have optional
dependencies. No automatic downloads, updates or services on shell startup.

```sh
git clone https://github.com/andre-hub/zsh.git zsh
cd zsh
sh ./install-deps.sh          # optional package guidance; installs nothing
zsh ./create-links.sh         # preview
zsh ./create-links.sh --apply # optional --tmux also links tmux.conf
zsh
```

Existing startup files, including dangling links, are never overwritten: back
up conflicts manually. Links use `$ZDOTDIR` (default `$HOME`); keep the checkout.
To make zsh your default login shell, use your system's shell-selection tool.

## Terminals without a matching terminfo entry

Hosts that were set up minimally often lack the terminfo entry a remote tmux
exports, `tmux-256color` in particular. Without it the terminal description
falls back to a stand-in and key sequences, colors and capabilities no longer
match what the terminal actually sends. `zshlib/terminfo-guard.zsh` runs before
the key bindings and repairs that at the source: if `$TERM` is absent from every
terminfo database, it compiles the bundled `terminfo/$TERM.ti` into the
account-local `~/.terminfo` with `tic`, which fixes the entry for every program,
not just zsh. Only if that is impossible does it fall back to the closest entry
that does exist, and it never touches a `$TERM` that resolves. `tests/terminfo-guard.zsh`
covers all three cases on a real pty.

## Modules and plugins

All modules explicitly listed in `zshrc` are enabled; plugins are opt-in.
Export switches before starting zsh (or in `zprofile` for login shells):

```sh
export ZSH_PUBLIC_DISABLE_MODULES="git.zsh:packer.zsh" # default: empty
export ZSH_PUBLIC_PLUGINS="git-alias.plugin.zsh:tmux.plugin.zsh" # default: empty
```

Disable any listed library by filename, e.g. `media.zsh`, `repo.zsh` or
`spectrum.zsh`. To add a library, place it in `zshlib/` and explicitly list it
in `zshrc`; to add a plugin, place it in `zshplugins/` and select its filename.
Only files resolving inside those directories load, once per shell. Restart
after changes. Review extensions before enabling them; never commit secrets.

| Bundled plugins (append `.plugin.zsh`) | Purpose / optional tools |
| --- | --- |
| `git-alias`, `git`, `github`, `golang`, `sql` | Git shortcuts/status, forge helpers, Go shortcuts, SQL (`psql`) |
| `fzf-completion`, `fzf-key-bindings`, `vi-mode` | `**` + Tab; Ctrl-T/Alt-C/Ctrl-R (`fzf`); Vi editing, either load order |
| `colored-man-pages`, `tmux`, `xfce` | Colored man (`less`); `ta`/`ts`/`tl`; desktop `browse` (`thunar`) |
| `debian`, `archlinux`, `cygwin`, `battery` | Platform shortcuts; battery (`acpi`/`pmset`/`acpiconf`) |
| `ssh-agent`, `gpg-agent` | Explicit `ssh_agent_use SOCKET` / `gpg_tty_refresh`; no autostart/key loading |

Set `FZF_COMPLETION_TRIGGER` (default `**`) or `apt_pref` (`apt-get`, `apt`,
`aptitude`) before use. Plugins never install tools.

## Helpers

| Commands | Behavior |
| --- | --- |
| `g`, `gco`, `gfe`, `gps`, `gpl`, `gst`, `gaa`, `gbr`, `gif` | git; commit; fetch all/tags/prune; push; pull ff-only; status -sb; add .; branch; diff |
| `gpa` | Pull main ff-only in clean direct child repositories; restore previous branches; skip unsafe states |
| `repo-open`, `repo-issues`, `repo-prs` | Browser / read-only lists (`gh` or `tea` + `jq`); default origin, optional `--remote NAME` |
| `repo-pr [--base BRANCH]` | Push current branch without force, then open PR form (default base main); confirm creation in browser |
| `..` … `.....`, `md`, `mcd`, `rd` | Parent navigation; mkdir -p; mkdir + cd; recursive removal after one confirmation |
| `ll`, `la`, `lsa`, `bookmark` | Listings; categorized searchable bookmarks with fzf into edit buffer, never auto-execute |
| `dl`, `pdfmerge`, `pdfresize`, `yt` | aria2 downloads; Ghostscript + Python 3 PDF merge/resize; yt-dlp |
| `chmodx`, `shebang zsh FILE`, `hardwareinfo` | Make executable then run; create new script and open editor; CPU/RAM summary |
| `spectrum_ls`, `spectrum_bls` | Foreground/background color charts; upstream attribution in `LICENSE.spectrum` |
| `to-mp3`, `to-opus`, `to-aac`, `to-flac`, `to-alac` | FFmpeg: 256k MP3, 192k VBR Opus, 256k AAC, lossless FLAC/ALAC |
| `to-mp4`, `to-hevc`, `to-av1` | FFmpeg: H.264 MP4 / HEVC MP4 / AV1 MKV; quality-based, no upscale/FPS change |
| `to-jpg`, `to-png`, `to-webp`, `to-avif`, `imgresize` | ImageMagick 7; single-frame conversion and fit-inside resizing |

Media commands accept a file list; no files means all suitable direct files,
never subdirectories. Example: `to-opus song.wav clip.mp4`; `imgresize 4k`;
`imgresize 1920x1080 one.jpg two.png`. Resize presets: `4k`=3840x2160,
`2k`=2560x1440, `fullhd`=1920x1080; no crop/upscale. Outputs stay alongside
originals (new extension; codec/resize suffix when needed); existing outputs
are skipped, originals untouched, errors summarized. Complex tracks, HDR,
animation and transparent-to-JPEG inputs are rejected rather than silently
flattened. Lossless conversion requires integer audio up to 24-bit. Higher
bitrate cannot restore lost source quality.

Gitea uses local Git config: `remote.NAME.forge=gitea`, `forgeWebUrl` (full HTTPS
repository URL, including any port/subpath), and `forgeLogin` (tea login), all
under `remote.NAME`. The tea login URL must match the server base including
subpath. GitHub lists need `gh`; Gitea lists need `tea` + `jq`. Browser/push
helpers work without these CLIs. PR push targets must match the selected repo.

## Command bookmarks

`bookmark` or **Alt-B** opens a searchable list with category colors and
highlighted matches. Enter copies the original command into the edit buffer,
without display color codes; it never runs the command. Press Enter again only
after checking or completing it. Escape preserves the existing buffer and
cursor. Alt-B is bound in Emacs and Vi insert mode; Ctrl-B is unchanged.

Provide your own optional `~/.config/zsh/bookmarks.tsv`, or set
`ZSH_BOOKMARK_FILE` before starting the shell. No command list is bundled.
Each nonempty line has three fields separated by literal tabs:
`category<TAB>description<TAB>command`. Lines beginning with `#` are comments.
Commands are read as data, not sourced or evaluated; quoting and empty argument
templates remain literal. Do not use embedded tabs, multiline commands or
secrets. Category names are arbitrary; colors cycle independently of their text.

`bookmark --legacy` reads only the existing `~/.zsh_bookmarks` (one command per
line), while `bookmark --all` combines it with the TSV entries. Neither file nor
shell history is changed. Missing optional sources are skipped; an empty list
is reported. `fzf` is required and is not installed automatically.

An explicitly loaded, trusted extension may define `_zsh_bookmark_extra` to add
entries when the selector is opened. It can call `_zsh_bookmark_read FILE` to
append another TSV to the selector-local `entries` and `rows` arrays. Return
nonzero to stop selection on failure. The selector does not discover or load
extensions, and `--legacy` does not call this hook. Keep target-specific lists
and providers outside this repository. Open a new shell after configuration
changes.

Tests: `zsh -d -f tests/all.zsh`. Platform stubs are not native platform tests.
License: [MIT](LICENSE).
