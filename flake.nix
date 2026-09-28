{
  description = "Experimental virtual machine monitor written from scratch in Rust";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ] (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = eachSystem (
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          # Guests run Linux on the host's architecture
          guestPkgs = nixpkgs.legacyPackages.${builtins.replaceStrings [ "darwin" ] [ "linux" ] system};
        in
        {
          alioth = pkgs.callPackage ./package.nix { };
          default = self.packages.${system}.alioth;
          initramfs = pkgs.callPackage ./initramfs.nix { inherit (guestPkgs.pkgsStatic) busybox; };
          vm = pkgs.callPackage ./vm.nix {
            inherit (self.packages.${system}) alioth initramfs;
            kernel = guestPkgs.linux;
          };
        }
      );
    };
}
