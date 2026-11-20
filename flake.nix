{
  description = "nix-darwin config for Allans-MacBook-Pro";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nix-darwin, ... }: {
    darwinConfigurations."Allans-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        ({ pkgs, lib, ... }: {
          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.config.allowUnfree = true; # terraform (BSL)

          # Determinate Nix owns the daemon and nix.conf; nix-darwin must not.
          nix.enable = false;

          system.primaryUser = "allanlacaba";
          users.users.allanlacaba.home = "/Users/allanlacaba";
          system.stateVersion = 6;

          # Homebrew after nix, so nix wins for tools both provide.
          environment.systemPath = lib.mkAfter [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

          environment.systemPackages = with pkgs; [
            # --- languages / toolchains (single global version) ---
            clojure
            babashka
            jdk11
            maven
            gradle
            dotnet-sdk_8
            roswell
            sbcl
            python312
            ansible
            rustup
            php
            php.packages.composer
            # ruby + node: many per-project versions -> mise handles them
            mise

            # --- cloud / infra ---
            awscli2
            python3Packages.cfn-lint
            rain
            cli53
            terraform
            kubectl
            trivy
            podman
            podman-compose

            # --- cli ---
            git
            bashInteractive
            curl
            gh
            jq
            just
            tmux
            htop
            coreutils
            stow
            cmake
            bear
            pandoc
            ripgrep
            eza
            starship
          ];

          # GUI apps + C libs that native gems link against stay in Homebrew.
          homebrew = {
            enable = true;
            # Anything brew-installed but not listed here is removed on switch.
            onActivation.cleanup = "uninstall";
            taps = [ "d12frosted/emacs-plus" ];
            brews = [
              # native gem deps (tiny_tds, pg, mysql2, ruby-vips) + ruby builds
              "freetds"
              "libpq"
              "mysql-client"
              "vips"
              "openssl@3"
              "libyaml"
              "gmp"
              "sceptre" # not in nixpkgs
              # emacs-plus-app runtime deps (cask deps are not protected from cleanup)
              "gcc"
              "libgccjit"
            ];
            casks = [
              # terminals / editors
              "ghostty"
              "emacs-plus-app" # Emacs 31, d12frosted/emacs-plus tap
              "jetbrains-toolbox"
              "antigravity"
              "t3-code"
              "claude"
              # dev
              "orbstack"
              "podman-desktop"
              "dbeaver-community"
              "bruno"
              "vagrant"
              "vagrant-manager"
              # browsers
              "firefox"
              "librewolf"
              "zen"
              "google-chrome"
              "microsoft-edge"
              # everything else
              "1password"
              "adguard"
              "karabiner-elements"
              "logi-options+"
              "sensiblesidebuttons"
              "nextcloud"
              "obsidian"
              "slack"
              "tailscale-app"
              "psychopy"
              # fonts
              "font-aporetic"
              "font-dejavu-sans-mono-nerd-font"
            ];
          };

        })
      ];
    };
  };
}
