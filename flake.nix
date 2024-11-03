{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages.x86_64-linux.default = pkgs.vimUtils.buildVimPlugin {
        pname = "ghcid-error-file-nvim";
        version = "0.0.1";
        src = ./src;
      };

      overlays.default = final: prev:
        {
          vimPlugins = prev.vimPlugins // {
            ghcid-error-file-nvim = self.defaultPackage.x86_64-linux;
          };
        };
    };
}
