let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQT5jLp3sX+tWW3OkxhOoKErVaDMfh/fuP+snI9L7Zz your_email@example.com";
  user2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICU4gLeeKJ2Dp3wtSBuAB1X9xwCHnJHNdzPTdkRXwi9o marius.nygard@wellstarter.com";
  users = [ user1 user2 ];

  #system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  #system2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzxQgondgEYcLpcPdJLrTdNgZ2gznOHCAxMdaceTUT1";
  #systems = [ system1 system2 ];
  systems = [ ];
in
{
  "claudeToken.age".publicKeys = users;
  "tstsecret.age".publicKeys = users ++ systems;
}
