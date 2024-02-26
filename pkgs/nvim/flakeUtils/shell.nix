{ pkgs, ... }:
{
  default = pkgs.mkShell {
    buildInputs = [
      pkgs.nixpkgs-fmt
      pkgs.selene
      pkgs.stylua
      pkgs.pre-commit
      #pkgs.lazygit
    ];
  };
}
