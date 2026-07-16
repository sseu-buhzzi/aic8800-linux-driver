# UGREEN AIC8800 Wi-Fi Linux driver

## How to configure it in nixos configuration

- An example for `flake.nix`.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    aic8800 = {
      # Or another revision that matches or is close to your kernel.
      url = "github:sseu-buhzzi/aic8800-linux-driver?ref=archive/38206003-linux-7.1.1";
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

- An example for `configuration.nix`.

```nix
{ ... }:

{
  hardware.aic8800.enable = true;
}
```
