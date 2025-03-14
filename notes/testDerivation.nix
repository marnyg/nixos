{ pkgs, ... }: {
  # note = stdenv.mkDerivation {
  #   name = "noteInStore";
  #   src = ./staticFileNote.md;
  # };
  note = pkgs.writeText "eval-note" "sllsl";
  output =
    let
      notebash = pkgs.writers.writeBash "eval-note" "echo 'value after eval of derivation'";
      output = pkgs.runCommand "capture-output" { } ''
        ${notebash} > $out
      '';
    in
    builtins.readFile output;
}
