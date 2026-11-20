<img src="assets/icon.svg" width="64" height="64" alt="">

# nix-mac

nix-darwin config for `Allans-MacBook-Pro` (aarch64, macOS 26). NixOS itself does not run on Apple Silicon Macs; nix-darwin is the macOS equivalent.

- CLI tools and language toolchains come from **nixpkgs**.
- GUI apps and the C libraries that native gems link against stay in **Homebrew**, but are listed declaratively in `flake.nix`.
- Ruby and Node (several versions across projects) stay on **mise**, which itself comes from nix.
- Nix is **Determinate Nix**, so `nix.enable = false` (Determinate manages the daemon).

## Apply

```sh
sudo darwin-rebuild switch --flake .#Allans-MacBook-Pro
```

Homebrew runs with `cleanup = "uninstall"`: add a formula or cask to `flake.nix` instead of running `brew install`, or the next switch removes it. Homebrew comes after nix on PATH, so nix wins where both have a tool.

## Migration (done 2026-11-20, in place, no reinstall)

- Removed MacPorts (`/opt/local`, broken after the OS upgrade) and asdf.
- Removed 29 brew formulae, pipx ansible, the curl-installed rustup and mise, the old Emacs build and 4 unused taps, since nix replaces them all.
- Removed atuin entirely, including its history and its config in `~/dotfiles`. Removed every terminal except Ghostty.
- Brought the existing apps under Homebrew (`--adopt`, or a reinstall for apps that use installer packages).
- The original `/etc` shell files were kept as `*.before-nix-darwin`, and `~/.zprofile` as `~/.zprofile.before-nix-darwin`.

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
- **Apps outside Homebrew**: Amphetamine, Telegram, Windows App and Apple apps (Mac App Store), FastScrobbler and KensingtonWorks (no cask). Use `homebrew.masApps` if you want the App Store ones declared too.
- **Overlap you may want to trim**: 5 browsers, and both OrbStack and Podman.
