{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      nvimWithMini =
        let
          config = pkgs.neovimUtils.makeNeovimConfig {
            plugins = [
              pkgs.vimPlugins.mini-nvim
            ];
          };
        in
        pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped config;
    in
    {
      packages.x86_64-linux.default = pkgs.vimUtils.buildVimPlugin {
        pname = "ghcid-error-file-nvim";
        version = "0.0.1";
        src = ./src;
      };

      checks.x86_64-linux.default = pkgs.runCommand "check" { } ''
        cd ${self}

        ${nvimWithMini}/bin/nvim \
          --headless \
          --noplugin \
          -u tests.lua \
          -c 'lua MiniTest.run()'

        touch $out
      '';

      overlays.default = final: prev:
        {
          vimPlugins = prev.vimPlugins // {
            ghcid-error-file-nvim = self.defaultPackage.x86_64-linux;
          };
        };
    };
}

