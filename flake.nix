{
  description = "A nix flake for UGREEN AIC8800 Linux driver";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      kernel = pkgs.linuxPackages_6_12.kernel;
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

            args=(
              CONFIG_PLATFORM_CUSTOM=y
              KDIR='${kernel.dev}/lib/modules/${kernel.modDirVersion}/build'
            )
            make "''${args[@]}"
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
    };
}
