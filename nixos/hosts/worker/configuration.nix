{ config, pkgs, ... }:
{
  imports = [ ./hardware.nix ];
  networking.hostName = "media-worker";

  services.k3s = {
    enable = true;
    role = "agent";
    token = config.secrets.k3sToken;
    serverAddr = "https://${config.cluster.masterIP}:6443";
  };

  fileSystems."/mnt/plex-media" = if config.cluster.installMode then { } else {
    device = "/dev/disk/by-uuid/${config.secrets.mediaDriveUUID}";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  systemd.tmpfiles.rules = if config.cluster.installMode then [ ] else [
    "d /mnt/plex-media 0777 ${config.cluster.username} users -"
  ];
}
