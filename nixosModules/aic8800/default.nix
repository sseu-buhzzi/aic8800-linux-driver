{ config, lib, pkgs, ... }:

{
  options.hardware.aic8800.enable =
    lib.mkEnableOption "AIC8800 WiFi driver";

  config = lib.mkIf config.hardware.aic8800.enable {
    boot = {
      extraModulePackages = [
        (config.boot.kernelPackages.callPackage ./driver.nix { })
      ];

      kernelModules = [ "aic8800_fdrv" ];
    };

    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "aic-udev";
        destination = "/lib/udev/rules.d/aic.rules";
        text = let eject = "${pkgs.util-linux}/bin/eject"; in ''
          KERNEL=="sd*", ATTRS{idVendor}=="a69c", ATTRS{idProduct}=="5721", SYMLINK+="aicudisk", RUN+="${eject} /dev/%k"
          KERNEL=="sd*", ATTRS{idVendor}=="a69c", ATTRS{idProduct}=="5722", SYMLINK+="aicudiskv2", RUN+="${eject} /dev/%k"
        '';
      })
    ];
  };
}
