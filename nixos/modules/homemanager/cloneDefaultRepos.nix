{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.cloneDefaultRepos = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.cloneDefaultRepos.enable
    {

      home.file."git/txt2" = { text = "generated by homemanager"; };


      systemd.user.services.cloneDefaultRepos =
        let
          cloneRepoScript = pkgs.writeShellScript "cloneRepos.sh" ''
            ${pkgs.git}/bin/git clone https://github.com/marnyg/nixos ~/git/nixos;
          '';
        in
        {
          #WantedBy = [ "multi-user.target" ];
          ServiceConfig = { Type = "oneshot"; };
          Unit.Description = "Example description";
          Service = { ExexStart = "${cloneRepoScript}"; };

      #script = ''
      #  ${pkgs.git}/bin/git clone https://github.com/marnyg/nixos ~/git/nixos;
      #'';
        };

    };
}
