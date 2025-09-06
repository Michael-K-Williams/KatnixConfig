{ config, pkgs, lib, ... }:

let
  # Get GPU information from hardware
  gpuInfo = builtins.readFile (pkgs.runCommand "gpu-info" {} ''
    ${pkgs.pciutils}/bin/lspci | grep -i 'vga\|3d\|display' > $out || echo "unknown" > $out
  '');
  
  # Detect GPU types
  hasNvidia = lib.strings.hasInfix "nvidia" (lib.strings.toLower gpuInfo);
  hasAMD = lib.strings.hasInfix "amd" (lib.strings.toLower gpuInfo) || lib.strings.hasInfix "radeon" (lib.strings.toLower gpuInfo);
  hasIntel = lib.strings.hasInfix "intel" (lib.strings.toLower gpuInfo);

in {
  # Choose kernel based on GPU
  boot.kernelPackages = if hasNvidia then pkgs.linuxPackages else pkgs.linuxPackages_latest;

  services.xserver = {
    # Set video drivers based on detected hardware
    videoDrivers = 
      lib.optional hasNvidia "nvidia" ++
      lib.optional hasAMD "amdgpu" ++
      lib.optional (!hasNvidia && !hasAMD) "modesetting";
  };

  # Enable thermal management and power saving for integrated graphics
  services.thermald.enable = lib.mkIf (hasIntel || hasAMD) true;

  # GPU configuration based on detected hardware
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      
      # Intel graphics packages
      extraPackages = with pkgs; lib.optionals hasIntel [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ] ++ lib.optionals hasAMD [
        # AMD graphics packages
        amdvlk
        rocmPackages.clr.icd
      ];
      
      extraPackages32 = with pkgs.driversi686Linux; lib.optionals hasIntel [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ] ++ lib.optionals hasAMD [
        amdvlk
      ];
    };

    # NVIDIA specific configuration
    nvidia = lib.mkIf hasNvidia {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    # AMD specific configuration
    amdgpu = lib.mkIf hasAMD {
      opencl.enable = true;
      amdvlk.enable = true;
    };
  };

  # Power management based on GPU
  powerManagement.cpuFreqGovernor = lib.mkIf (hasIntel && !hasNvidia) "powersave";

  # Environment variables for graphics
  environment.sessionVariables = lib.mkMerge [
    (lib.mkIf hasIntel {
      LIBVA_DRIVER_NAME = "iHD";
    })
    (lib.mkIf hasAMD {
      AMD_VULKAN_ICD = "RADV";
    })
  ];
}