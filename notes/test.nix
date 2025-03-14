{ lib, ... }: {
  note1 = [ 1 2 3 ] |> map (x: "This is a test: ${toString x}\n");
  note2 = [ 1 2 3 ] |> map (x: "This is a test: ${toString x}\n") |> lib.concatStringsSep "\n";
}
