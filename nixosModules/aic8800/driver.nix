{ stdenv, kernel, ... }:

let
  aic8800-firmware = stdenv.mkDerivation {
    name = "aic8800-firmware";
    src = ../../fw/aic8800DC;

    installPhase = ''
      mkdir -p "$out/lib/firmware/aic8800DC"
      cp -rt "$out/lib/firmware/aic8800DC" '.'
    '';
  };
in
stdenv.mkDerivation {
  pname = "aic8800-driver";
  version = "1.1.0";

  src = ../../drivers/aic8800;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    args=(
      CONFIG_PLATFORM_CUSTOM=y
      KDIR='${kernel.dev}/lib/modules/${kernel.modDirVersion}/build'
      AIC_DEFAULT_FW_PATH='"${aic8800-firmware}/lib/firmware"'
    )
    make "''${args[@]}"
  '';

  installPhase = ''
    mod_dest_dir="$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/aic8800"
    mkdir -p "$mod_dest_dir"

    args=(
      -m 644
      -p
      -t "$mod_dest_dir"
      'aic_load_fw/aic_load_fw.ko'
      'aic8800_fdrv/aic8800_fdrv.ko'
    )
    install "''${args[@]}"
  '';
}
