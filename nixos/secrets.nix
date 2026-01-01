{
  # Networking
  masterIP = "192.168.1.91";
  workerIP = "192.168.1.56";
  gateway = "192.168.1.1";
  domain = "cluster.local";
  metallbIPRange = "192.168.1.200-192.168.1.210";

  # Secrets
  k3sToken = "REPLACE_THIS_WITH_A_LONG_RANDOM_STRING";
  mediaDriveUUID = "1234-5678-abcd-ef00";

  # User
  username = "nverk";
  userPassword = "$6$3ND1F8NNh0JoRTJ7$k9G17AbSV7oNp/Ebj07w.AmJPkr5UAz5Fqk5eMCTTZXQzra.uBFxrf0RhnhSsYvo30.2GR3.6kA17Hc8dhO89/";
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoVotkT+jNCRAtiZM+tQSh/grcNL17yldLsy1OhnsSb nverkhachoyan@iloveyou-2.local";
  installMode = true;
}

