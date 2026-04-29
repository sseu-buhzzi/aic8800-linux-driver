{
  description = "A nix flake for UGREEN AIC8800 Linux driver";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosModules.aic8800 = import ./nixosModules/aic8800/default.nix;

      defaultPackages.${system} =
        self.packages.${system}.aic8800-driver;

      packages.${system} = {
        default = self.packages.${system}.aic8800-driver;

        aic8800-driver = pkgs.linuxPackages.callPackage
          ./nixosModules/aic8800/driver.nix
          { };
      };

      devShells.${system}.default =
        let
          kernel = pkgs.linuxPackages.kernel;
        in
        pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.aic8800-driver ];

          nativeBuildInputs = with pkgs; [
            bear
          ];

          shellHook = ''
            echo 'It is a dev environment for UGREEN AIC8800 Linux driver'
            echo 'Kernel version: ${kernel.modDirVersion}'

            export KDIR='${kernel.dev}/lib/modules/${kernel.modDirVersion}/build'
            export ARCH='x86_64'
          '';
        };
    };
}
