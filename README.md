# UGREEN AIC8800 Wi-Fi Linux driver

An example for `flake.nix`.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    aic8800 = {
      url = "github:sseu-buhzzi/aic8800-linux-driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, aic8800, ... }:
    let
      system = "x86_64-linux";
      host = "<host>";
    in
    {
      nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix

          aic8800.nixosModules.aic8800
        ];
      };
    };
}
```

An example for `configuration.nix`.

```nix
{ ... }:

{
  hardware.aic8800.enable = true;
}
```
