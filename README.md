<img src="assets/icon.svg" width="64" height="64" alt="">

# nix-mac

nix-darwin config for `Allans-MacBook-Pro` (aarch64, macOS 26). NixOS itself does not run on Apple Silicon Macs; nix-darwin is the macOS equivalent.

- CLI tools and language toolchains come from **nixpkgs**.
- GUI apps and the C libraries that native gems link against stay in **Homebrew**, but are listed declaratively in `flake.nix`.
- Ruby and Node (several versions across projects) stay on **mise**, which itself comes from nix.
- Nix is **Determinate Nix**, so `nix.enable = false` (Determinate manages the daemon).

## Apply

```sh
# first time (no darwin-rebuild on PATH yet)
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#Allans-MacBook-Pro
# after that
sudo darwin-rebuild switch --flake .#Allans-MacBook-Pro
```

## Migration: in place, no reinstall

Don't wipe macOS or Nix. Nix is already a clean Determinate install, and Homebrew can be adopted gradually (`cleanup = "none"` means nix-darwin deletes nothing yet).

1. **Remove MacPorts.** It's broken ("OS platform mismatch") and only provides a stale emacs/gcc: `sudo rm -rf /opt/local /Applications/MacPorts /Library/LaunchDaemons/org.macports.*`
2. **Swap Emacs.** `brew uninstall --cask emacs-app` so `/Applications/Emacs.app` is free. On switch, the `emacs-plus-app` cask (Emacs 31) installs there.
3. **Switch.** Run the command under Apply. nix-darwin writes `/etc/zshrc` so `/run/current-system/sw/bin` is on PATH.
4. **Remove duplicates installed outside nix**, then check `which <tool>`:
   - `brew uninstall asdf awscli cfn-lint clojure cmake coreutils gh git htop jq just kubernetes-cli maven node openjdk@11 pandoc pipx podman-compose python@3.11 python@3.12 rain roswell stow tmux trivy bear cli53 dotnet@8 cryptography` (brew refuses if something still depends on one, so leave that one installed)
   - `pipx uninstall ansible`, then delete the ansible argcomplete `eval` lines in `.zshrc`.
   - `rustup self uninstall`, then `rustup default stable` with the nix rustup. Keep `$HOME/.cargo/bin` on PATH for `cargo install`ed tools, and drop the three `. "$HOME/.cargo/env"` lines.
   - `rm -rf ~/.atuin` and remove the `~/.atuin/bin/env` lines and the zinit `starship`/`atuin` loads, since nix provides both.
   - `rm ~/.local/bin/mise` (nix provides mise).
   - Remove other terminals (Ghostty only): `brew uninstall --cask --zap alacritty kitty wezterm` and drag `iTerm.app` to the Trash.
   - Untap unused taps: `brew untap homebrew/cask-fonts jank-lang/jank jimeh/emacs-builds railwaycat/emacsmacport`
5. **Adopt Homebrew fully.** Once `brew leaves` / `brew list --cask` show only what's in `flake.nix`, set `homebrew.onActivation.cleanup = "uninstall"`.

Those `.zshrc` edits go in `~/dotfiles/zsh/dot-zshrc` (stow). This repo doesn't manage dotfiles yet.

## What's on the machine

| Language / stack | Evidence | Where it lives now |
|---|---|---|
| Ruby (main language, 3.1.6 / 3.3.x / 4.0.x) | 14 Gemfiles, `.ruby-version` files | mise |
| Node 20 / 24 | 6 package.json, global npm CLIs | mise |
| Python 3.12, Ansible | pyproject, PyCharm, pipx ansible | nix |
| Java 11, Maven, Gradle, Grails 3.2.4 | build.gradle, IntelliJ | nix (Grails stays on sdkman: 3.2.4 isn't in nixpkgs) |
| Clojure, Babashka | brew clojure, mise bb | nix |
| Common Lisp | roswell | nix (roswell + sbcl) |
| Rust | rustup, rg/exa via cargo | nix rustup (rg/eza from nix) |
| .NET 8 | dotnet@8 | nix |
| PHP | composer.json, PhpStorm | nix (php + composer) |
| Emacs Lisp | `~/dot-emacs.d` | emacs-plus-app cask (Emacs 31) |
| Infra: AWS CLI, CloudFormation (cfn-lint, rain, sceptre), Terraform, kubectl, trivy | `projects/infra` | nix (sceptre via brew: not in nixpkgs) |
| Containers | OrbStack, Podman, Vagrant | casks + nix podman |

## Not done yet

- **home-manager**: dotfiles stay on stow. Add it if you want zsh/git/tmux config in nix.
- **Per-project toolchains**: mise is fine for now. Move to `devShell` + direnv per repo if you want one tool.
- **Apps outside Homebrew**: Amphetamine and Apple apps (Mac App Store), FastScrobbler and KensingtonWorks (no cask). Use `homebrew.masApps` if you want the App Store ones declared too.
- **Overlap you may want to trim**: 5 browsers, and both OrbStack and Podman.
