{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      });
    in
    {
      packages = forAllSystems
        (system:
          {
            default = nixpkgsFor.${system}.vimPlugins.ghcid-error-file-nvim;
          });

      checks = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          nvimWithMini = pkgs.wrapNeovim pkgs.neovim-unwrapped {
            configure.packages.default.start = [ pkgs.vimPlugins.mini-nvim ];
          };
        in
        {
          default = pkgs.runCommand "check" { } ''
            cd ${self}

            ${nvimWithMini}/bin/nvim \
              --headless \
              --noplugin \
              -u tests.lua \
              -c 'lua MiniTest.run();'

            touch $out
          '';
        });

      overlays.default = final: prev:
        {
          vimPlugins = prev.vimPlugins // {
            ghcid-error-file-nvim =
              prev.vimUtils.buildVimPlugin {
                pname = "ghcid-error-file-nvim";
                version = "0.0.1";
                src = ./.;
                nvimRequireCheck = "ghcid-error-file";
              };
          };
        };
    };
}

