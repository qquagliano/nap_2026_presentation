{
  description = "Quarto, Python, R, & Julia Development Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixpkgs_legacy.url = "github:NixOS/nixpkgs/f03c983c83471408ef16fcb9f47078491070064f";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/master";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs_legacy,
      flake-utils-plus,
      ...
    }:
    flake-utils-plus.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        pkgs_legacy = import nixpkgs_legacy {
          inherit system;
        };
        python = (
          pkgs.python3.withPackages (python-pkgs: [
            python-pkgs.ipython
            python-pkgs.numpy
            python-pkgs.pandas
            python-pkgs.radian
            python-pkgs.scipy
            python-pkgs.plotly
            python-pkgs.jupyter
          ])
        );
        julia = (
          pkgs.julia-bin.withPackages [
            "LanguageServer"
            "DataFrames"
            "DataFramesMeta"
          ]
        );
        R = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [
            dplyr
            egg
            furrr
            ggplot2
            kableExtra
            knitr
            languageserver
            magrittr
            quarto
            stringr
            tibble
            tidyr
            tidyselect
          ];
        };

        # BUG: Newer version of Tex breaks table coloring
        # Nix PR must have landed sometime between Mar 1 and May 18, 2025
        # I suspect: https://github.com/NixOS/nixpkgs/pull/390498
        # On new TeX, if rendered with Quarto -> breaks
        # if rendered with plain lualatex -> doesn't break

        auto-multiple-choice = pkgs.auto-multiple-choice;
        tex = (
          pkgs.texlive.combine {
            inherit (pkgs.texlive) scheme-full;
            inherit auto-multiple-choice;
          }
        );
        auto-multiple-choice_legacy = pkgs_legacy.auto-multiple-choice;
        tex_legacy = (
          pkgs_legacy.texlive.combine {
            inherit (pkgs_legacy.texlive) scheme-full;
            inherit auto-multiple-choice_legacy;
          }
        );

        nativeBuildInputs = with pkgs; [
          # python
          # julia
          # jupyter-all # For jupyter kernel rendering in Quarto
          mermaid-cli
          R
          quarto
          pandoc
          tex
        ];
      in
      {
        devShells.default = pkgs.mkShell {

          inherit nativeBuildInputs;

          shellHook =
            # bash
            ''
              echo " "
              echo "----- Initialized Quarto & R Development Environment -----"
              echo " "
            '';
        };
      }
    );
}
