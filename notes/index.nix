let
  pkgs = import <nixpkgs> { };
in
{
  metadata = { };
  note = /* markdown*/ ''
    # test
    Hello, World!
  '';
  note2 = /* norg */ ''
    * tst
     - [test](./test.norg)
    ** tst
    # test
    Hello, World!
  '';
  nixEvalNote = (import ./test.nix { lib = pkgs.lib; });
  nixEvalDerivation = (import ./testDerivation.nix { pkgs = pkgs; });
  staticFileNote = ./staticFileNote.md;
}
