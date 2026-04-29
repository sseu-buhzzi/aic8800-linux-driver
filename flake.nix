{
  description = "A nix flake for UGREEN AIC8800 Linux driver";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      kernel = pkgs.linuxPackages_6_18.kernel;
      kdir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
    in
    {
      defaultPackages.${system} = self.packages.${system}.aic8800-driver;

      packages.${system} = {
        default = self.packages.${system}.aic8800-driver;

        aic8800-driver = pkgs.stdenv.mkDerivation {
          pname = "aic8800-driver";
          version = "1.1.0";
          src = ./.;

          nativeBuildInputs = [ kernel ];

          buildPhase = ''
            cd 'drivers/aic8800'

            make CONFIG_PLATFORM_CUSTOM=y KDIR='${kdir}'
          '';

          installPhase = ''
            mod_dest_dir="$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/aic8800"
            mkdir -p "$mod_dest_dir"

            args=(
              MODDESTDIR="$mod_dest_dir"
              install
            )
            make "''${args[@]}"
          '';
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ self.packages.${system}.aic8800-driver ];

        nativeBuildInputs = with pkgs; [
          bear
        ];

        shellHook = ''
          echo 'It is a dev environment for UGREEN AIC8800 Linux driver'
          echo 'Kernel version: ${kernel.modDirVersion}'

          export KDIR='${kdir}'
          export ARCH='x86_64'
        '';
      };
    };
}
