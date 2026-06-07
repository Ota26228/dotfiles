{ config, lib, pkgs, modulesPath, ... }:
{
  # ★スタブ（事前ビルド検証用）。install 当日に実機ISOで
  #   `nixos-generate-config --no-filesystems --root /mnt` を実行し、
  #   生成された本物の hardware-configuration.nix で置き換えること。
  #   （filesystems は disko.nix が提供するので --no-filesystems）
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
