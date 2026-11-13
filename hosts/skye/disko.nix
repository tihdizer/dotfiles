{ inputs, ... }:
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.skye-disko =
    { config, lib, ... }:
    {
      imports = lib.optional (inputs ? disko) inputs.disko.nixosModules.disko;

      boot.supportedFilesystems = [
        "btrfs"
        "vfat"
      ];

      boot.tmp.useTmpfs = false;
      boot.tmp.cleanOnBoot = true;

      fileSystems."/nix".neededForBoot = true;
      fileSystems."/persistent".neededForBoot = true;

      disko.devices = {
        # 1. Ephemeral Root in RAM
        nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=4G"
            "mode=755"
          ];
        };

        disk = {
          # 2. NVMe SSD (1 TB System Disk)
          nvme = {
            type = "disk";
            device = lib.mkDefault "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNX1W606138B";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  priority = 1;
                  size = "1G";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                root = {
                  priority = 2;
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      "@nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@persistent" = {
                        mountpoint = "/persistent";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@steam" = {
                        mountpoint = "/home/tihdizer/.local/share/Steam";
                        mountOptions = [
                          "nodatacow"
                          "noatime"
                        ];
                      };
                    };
                  };
                };
              };
            };
          };

          # 3. First SATA SSD (240 GB) - Swap + RAID0 component
          sata1 = {
            type = "disk";
            device = lib.mkDefault "/dev/disk/by-id/ata-KINGSTON_SV300S37A240G_50026B723903D4ED";
            content = {
              type = "gpt";
              partitions = {
                swap = {
                  priority = 1;
                  size = "16G";
                  content = {
                    type = "swap";
                    priority = 1;
                  };
                };
                ssd = {
                  priority = 2;
                  size = "100%";
                };
              };
            };
          };

          # 3. Second SATA SSD (240 GB) - Swap + Btrfs RAID0 pool (/mnt/ssd)
          sata2 = {
            type = "disk";
            device = lib.mkDefault "/dev/disk/by-id/ata-TS240GMTS420S_F169321217";
            content = {
              type = "gpt";
              partitions = {
                swap = {
                  priority = 1;
                  size = "16G";
                  content = {
                    type = "swap";
                    priority = 1;
                  };
                };
                ssd = {
                  priority = 2;
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = [
                      "-f"
                      "-d"
                      "raid0"
                      "-m"
                      "raid0"
                      "/dev/disk/by-partlabel/disk-sata1-ssd"
                    ];
                    mountpoint = "/mnt/ssd";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };

          # 4. First HDD (2 TB) - RAID1 component
          hdd1 = {
            type = "disk";
            device = lib.mkDefault "/dev/disk/by-id/ata-WDC_WD20EFRX-68AX9N0_WD-WMC1T2574554";
            content = {
              type = "gpt";
              partitions = {
                archive = {
                  priority = 1;
                  size = "100%";
                };
              };
            };
          };

          # 4. Second HDD (2 TB) - Btrfs RAID1 pool (/mnt/archive)
          hdd2 = {
            type = "disk";
            device = lib.mkDefault "/dev/disk/by-id/ata-ST2000DM001-1ER164_Z4Z0BLKM";
            content = {
              type = "gpt";
              partitions = {
                archive = {
                  priority = 1;
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = [
                      "-f"
                      "-d"
                      "raid1"
                      "-m"
                      "raid1"
                      "/dev/disk/by-partlabel/disk-hdd1-archive"
                    ];
                    mountpoint = "/mnt/archive";
                    mountOptions = [
                      "compress=zstd"
                      "autodefrag"
                    ];
                  };
                };
              };
            };
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d /mnt/ssd 0755 root root -"
        "d /mnt/ssd/tihdizer 0700 tihdizer users -"
        "d /mnt/ssd/tihdizer/games 0700 tihdizer users -"
        "d /mnt/ssd/tihdizer/vms 0700 tihdizer users -"
        "d /mnt/ssd/shared 0777 root root -"
        "d /mnt/ssd/.Trash 1777 root root -"
        "d /mnt/ssd/.Trash/1000 0700 tihdizer users -"
        "d /mnt/ssd/.Trash-1000 0700 tihdizer users -"
        "d /mnt/archive 0755 root root -"
        "d /mnt/archive/tihdizer 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/downloads 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/documents 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/notes 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/desktop 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/music 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/pictures 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/pictures/screenshots 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/videos 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/templates 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/games 0700 tihdizer users -"
        "d /mnt/archive/tihdizer/vms 0700 tihdizer users -"
        "d /mnt/archive/shared 0777 root root -"
        "d /mnt/archive/.Trash 1777 root root -"
        "d /mnt/archive/.Trash/1000 0700 tihdizer users -"
        "d /mnt/archive/.Trash-1000 0700 tihdizer users -"
      ];
    };
}
