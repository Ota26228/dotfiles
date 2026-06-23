{
  # 宣言的ディスク構成: nvme0n1 を全消去して
  #   ESP(1G/FAT32) + LUKS(残り全部) → btrfs サブボリューム分割
  # ※ install 当日 `disko --mode disko` を実行するとこの通りに作られる
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";        # 本体SSD（lsblk で確認済み）
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;   # SSDのTRIM許可
            settings.crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-pcrs=0+7" ];
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
