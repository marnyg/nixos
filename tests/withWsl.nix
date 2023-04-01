{ pkgs, inputs }:
{
  name = "my-nixos-test";
  #extraBaseModules = [ inputs ];
  nodes = {
    # Define your test nodes (virtual machines) and their configurations
    machine = { ... }: {
      imports = [ inputs.nixos-wsl.nixosModules.wsl ];

      wsl = {
        enable = true;
        wslConf.automount.root = "/mnt";
        defaultUser = "nixos";
        startMenuLaunchers = true;

        # Enable native Docker support
        # docker-native.enable = true;

        # Enable integration with Docker Desktop (needs to be installed)
        # docker-desktop.enable = true;

      };

      # Enable nix flakes
      nix.package = pkgs.nixFlakes;
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';

      system.stateVersion = "22.11";

    };
  };

  testScript = ''
    # Python test script using the `nixosTest.driver` Python library
    start_all()  # Start all nodes

    machine.wait_for_unit("default.target")  # Wait for the machine to boot
    machine.succeed("echo 'Machine is up and running'")  # Run a basic command

    #machine.succeed("test  /home/mar")  # Run a basic command
    #users=machine.succeed("cat /etc/passwd")
    #print(users)


    # Add your assertions and test commands
    #assert "mar" in users, "user is created"
    assert True, "lal"
  '';
}
