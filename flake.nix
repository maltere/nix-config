{
  description = "Full Flake Panic!";

  inputs = {
    # nixpkgs = { url = "github:nixos/nixpkgs/nixos-23.05"; };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    # disabling this cause cause it's the same as `nixpkgs` atm (and it uses storage/network DL)
    # nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    # nixpkgs-unstable = nixpkgs; # requires `inputs = rec {`. works, but duplicates the input, doesn't reference it

    nixpkgs-pkgs-unstable = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };

    # disabling this cause I don't need it currently (and it uses storage/network DL)
    # nixpkgs-master = { url = "github:nixos/nixpkgs/master"; };

    # disabling this cause I didn't have a ~/gits/nixpkgs lying around
    # nixpkgs-local = { url = "/home/malte/gits/nixpkgs"; };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      flake = true;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    darwin = {
      url =  "github:nix-darwin/nix-darwin";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # for emacsGcc; see https://gist.github.com/mjlbach/179cf58e1b6f5afcb9a99d4aaf54f549
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    home-manager = {
      # url = "github:nix-community/home-manager/release-23.05";
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      # Should be the other way around (according to README.md), but don't wanna for now.
      # Also, this causes local rebuilds :)
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    fish-foreign-env = {
      url = "github:oh-my-fish/plugin-foreign-env";
      flake = false;
    };

    fish-puffer-fish = {
      url = "github:nickeb96/puffer-fish";
      flake = false;
    };

    fish-tide = {
      url = "github:IlanCosman/tide";
      flake = false;
    };

    doom-emacs = {
      url = "github:hlissner/doom-emacs";
      flake = false;
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    # https://isd-project.github.io/isd/
    isd = {
      url = "github:isd-project/isd";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # cf-engineering-nixpkgs = {
    #   url = "git+ssh://git@bitbucket.cfdata.org/~terin/engineering-nixpkgs";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      ...
    }@inputs:
    let
      flake-inputs = inputs;
    in
    {
      darwinConfigurations."hm-cf" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        specialArgs = {
          flake-inputs = inputs;
          system = "aarch64-darwin";
        };

        # Specify your darwin configuration modules here
        modules = [
          nix-homebrew.darwinModules.nix-homebrew

          {
            nix-homebrew = {
              enable = true;

              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };
            };

            homebrew = {
              enable = true;

              onActivation = {
                cleanup = "zap";
              };

              brews = [
                "cloudflared"
                "cmake"
                "ollama"
                "kubie"
                "kubernetes-cli"
                "grepcidr"
                "lua"
                "repomix"
                "protobuf"
                "golangci-lint"
              ];
            };
          }

          ./hosts/hm-cf/darwin.nix

          # Add home-manager's darwin module
          # home-manager.darwinModules.home-manager
          home-manager.darwinModules.home-manager

          inputs.mac-app-util.darwinModules.default

          ({ pkgs, ... }: {
            # Replicate the pkgs configuration from the old home-manager standalone config
            nixpkgs.config = {
              # explicitly manage which unfree packages I allow in this config
              allowUnfreePredicate =
                pkg:
                builtins.elem (pkgs.lib.getName pkg) [
                  "spotify" # allowed + need music
                  "sublime-merge" # unfree license, but explicitly has an "unrestricted evaluation period", i.e., no time limit
                  "tableplus" # unfree, but has tab-/window-limit in the free version, that's it
                  # "gitbutler" # unfree, but free for individual developers, plus no pricing exists yet (2025-03-24)
                  "vault" # unfree, but we use this at CF (2025-04-09)
                  "vault-bin" # unfree, but we use this at CF (2025-04-09)
                ];
            };

            nixpkgs.overlays = [
              (final: prev: {
                lib = prev.lib // {
                  my = {
                    editorTools = (
                      with final;
                      [
                        # misc
                        jq
                        editorconfig-core-c

                        # markdown
                        multimarkdown
                        markdownlint-cli2
                        marksman

                        # shell
                        shfmt
                        shellcheck

                        # python
                        black
                        python3Packages.pyflakes
                        python3Packages.isort
                        pyright

                        # nix
                        nil # nix lsp
                        nixd # better nix lsp?
                        nixfmt-rfc-style

                        # go
                        gopls
                        gotools
                        gofumpt
                        gomodifytags
                        impl

                        # tex
                        # texlab

                        # typst
                        # typst-lsp # currently broken due to Rust 1.80 `time`-fallout
                        typstfmt
                        # typst-live

                        # scala
                        metals

                        # dhall
                        # dhall-lsp-server # currently (2023-08-19) broken

                        # lua
                        stylua
                        lua-language-server

                        # jsonls
                        nodePackages.vscode-json-languageserver

                        # js/ts (:
                      ]
                    );
                    mkWrappedWithDeps =
                      {
                        pkg,
                        pathsToWrap,
                        prefix-deps ? [ ],
                        suffix-deps ? [ ],
                        extraWrapProgramArgs ? [ ],
                        otherArgs ? { },
                      }:
                      let
                        prefixBinPath = prev.lib.makeBinPath prefix-deps;
                        suffixBinPath = prev.lib.makeBinPath suffix-deps;
                      in
                      prev.symlinkJoin (
                        {
                          name = pkg.name + "-wrapped";
                          paths = [ pkg ];
                          buildInputs = [ final.makeWrapper ];
                          postBuild = ''
                            cd "$out"
                            for p in ${builtins.toString pathsToWrap}
                            do
                              wrapProgram "$out/$p" \
                                --prefix PATH : "${prefixBinPath}" \
                                --suffix PATH : "${suffixBinPath}" \
                                ${builtins.toString extraWrapProgramArgs}
                            done
                          '';
                        }
                        // otherArgs
                      );
                  };
                };
              })
              # inputs.cf-engineering-nixpkgs.overlay
            ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.malte.imports = [
              ./hosts/hm-cf/home.nix
            ];
            home-manager.extraSpecialArgs = {
              flake-inputs = inputs;
              thisFlakePath = self;
              system = "aarch64-darwin";
              # thisFlakePath = "/Users/malte/playground/configs/nix-config";
            };

            # Declare the user for nix-darwin system management
            users.users.malte = {
              home = "/Users/malte";
            };

            # Recommended to set this. 4 is the latest as of now.
            system.stateVersion = 4;
          })
        ];
      };

      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
      };
    };
}
