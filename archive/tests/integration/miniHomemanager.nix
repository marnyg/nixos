inputs:
{
  name = "my-nixos-test";
  nodes = {
    # Define your test nodes (virtual machines) and their configurations
    machine = { pkgs, ... }: {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      users.users.mar = {
        shell = pkgs.bash;
        isNormalUser = true;
        group = "mar";
      };
      users.groups.mar = { };
      home-manager.users.mar = {
        home = {
          stateVersion = "22.11";
          username = "mar";

          packages = [ pkgs.vim ];
        };
      };
      # Additional NixOS configuration specific to this test
    };
  };

  testScript = ''
    # Python test script using the `nixosTest.driver` Python library
    start_all()  # Start all nodes

    machine.wait_for_unit("default.target")  # Wait for the machine to boot
    machine.succeed("echo 'Machine is up and running'")  # Run a basic command

    machine.succeed("test  /home/mar")  # Run a basic command
    users=machine.succeed("cat /etc/passwd")
    print(users)


    # Add your assertions and test commands
    assert "mar" in users, "user is created"
  '';
}
