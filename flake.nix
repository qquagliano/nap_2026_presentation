{
  description = "NAP 2026 Conference Presentation Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/master";
  };

  outputs =
    {
      nixpkgs,
      flake-utils-plus,
      ...
    }:
    # Builds for all possible system architectures
    flake-utils-plus.lib.eachDefaultSystem (
      system:
      let
        quarto_ver = "1.9.16";
        # Necessary to call nixpkgs below, do not remove
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              quarto = prev.quarto.overrideAttrs (old: {
                version = quarto_ver;
                src = prev.fetchurl {
                  url = "https://github.com/quarto-dev/quarto-cli/releases/download/v${quarto_ver}/quarto-${quarto_ver}-linux-amd64.tar.gz";
                  hash = "sha256-Up/4/WTP2MYCNWfIf3Og0TthNYyk1sYPHNNksqKvJU8=";
                };
                patches = [
                ];
              });
            })
          ];
        };
        # Set here so it can be included in both Quarto and R wrappers below
        R_packages = with pkgs.rPackages; [
          kableExtra
          knitr
          languageserver # For R LSP support in text editors/IDEs
          magrittr
          quarto
          renv
          sessioninfo
        ];
        # Make R and Quarto with packages above
        my_R = pkgs.rWrapper.override {
          packages = R_packages;
        };
        my_quarto = pkgs.quarto.override {
          extraRPackages = R_packages;
        };
        # Set up tex
        my_tex = pkgs.texliveFull;
        nativeBuildInputs = with pkgs; [
          # CLI tools
          bashInteractive # For a basic shell on
          flake-checker # For ensuring flake is healthy and up-to-date
          # Custom R and Quarto tools
          my_R
          my_quarto
          # Rendering dependencies
          pandoc
          my_tex
          liberation_ttf # For FOSS fonts
        ];
      in
      {
        devShells.default = pkgs.mkShell {

          inherit nativeBuildInputs;

          shellHook =
            # bash
            ''
              echo " "
              echo -e "\e[32m----- Initialized Nix Flake Development Environment -----\e[0m"
              echo " "

              out=$(git --no-pager fetch --dry-run 2>&1)
              if [ -n "$out" ]
              then    
              echo -e "\e[31m----- Local git repo is behind Github remote or unreachable, Consider git pulling before further work ----- <<--\e[0m"
              echo " "
              while true; do
              read -p "----- Do you want to git pull? (y/n) ----- " yn
              case $yn in 
                [yY] ) 
                  echo " ";
                  git pull;
                  break;;
                [nN] ) 
                  echo " ";
                  echo -e "\e[31m----- WARNING: Editing repo without git pulling ----- <<--\e[0m";
                  exit;;
                * ) echo invalid response;;
              esac
              done
              else
              echo -e "\e[32m----- Local git repo is up to date with Github remote -----\e[0m"
              fi

              echo -e " "
              echo -e "\e[32m----- Setting git root directory, .Rprofile and fonts location -----\e[0m"
              export GIT_ROOT_DIR=$(git rev-parse --show-toplevel)
              export R_PROFILE_USER="$(echo $GIT_ROOT_DIR)/.Rprofile" 
              export OSFONTDIR=${pkgs.liberation_ttf}/share/fonts

              if [[ -f $R_PROFILE_USER  &&  -d $GIT_ROOT_DIR/renv ]]; 
              then
                echo -e " "
                echo -e "\e[32m----- .Rprofile and renv directory found -----\e[0m"
              else
                echo -e " "
                echo -e "\e[31m----- Missing .Rprofile and/or renv directory ----- <<--\e[0m"
              fi

              echo -e " "
              out="$($(flake-checker --no-telemetry --fail-mode > ./flake_check_results) echo $?)"
              if [ "$out" = 1 ]
              then
              echo -e "\e[31m----- Flake check gives warnings: ----- <<--\e[0m"
              echo -e " "
              cat ./flake_check_results
              rm -rf ./flake_check_results
              else
              echo -e "\e[32m----- Flake check gives good status -----\e[0m"
              rm -rf ./flake_check_results
              fi

              export LATEXMKRCSYS=$(echo $GIT_ROOT_DIR/.latexmkrc)

              echo -e " "
              echo -e "\e[32m----- Finished Nix Flake Development Environment Init Process -----\e[0m"
              echo -e " "
            '';
        };
      }
    );
}
