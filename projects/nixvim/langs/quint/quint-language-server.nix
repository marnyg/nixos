# quint-language-server — LSP server for the Quint specification language.
#
# Not in nixpkgs (only the `quint` CLI is), but it lives in the same repo as
# the CLI, so we build it from `pkgs.quint.src` to stay version-aligned with
# whatever nixpkgs pins.
{ lib, buildNpmPackage, importNpmLock, quint }:

buildNpmPackage {
  pname = "quint-language-server";
  # The server is versioned independently from the `quint` CLI; read it out of
  # the source tree so it can't drift from what we actually build.
  version = (lib.importJSON "${quint.src}/vscode/quint-vscode/server/package.json").version;

  src = quint.src;
  sourceRoot = "${quint.src.name}/vscode/quint-vscode/server";

  # Deps come from the server's own package-lock.json, each fetched by the
  # integrity hash npm recorded there: no npmDepsHash to re-pin by hand
  # every time nixpkgs bumps quint.
  npmDeps = importNpmLock {
    npmRoot = "${quint.src}/vscode/quint-vscode/server";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  npmBuildScript = "compile";

  # `out/` requires the runtime deps (@informalsystems/quint et al.) at run time.
  dontNpmPrune = true;

  # Upstream builds the server inside the VSCode extension workspace, where
  # `vscode-languageclient` is hoisted in from the client package. Standalone,
  # it isn't in the server's package-lock, so `tsc -b` fails. The import is
  # type-only (`MarkupContent`), and `vscode-languageserver` re-exports it.
  postPatch = ''
    substituteInPlace src/complete.ts \
      --replace-fail "from 'vscode-languageclient'" "from 'vscode-languageserver'"
  '';

  meta = {
    description = "Language server for the Quint formal specification language";
    homepage = "https://quint-lang.org";
    license = lib.licenses.asl20;
    mainProgram = "quint-language-server";
    platforms = lib.platforms.unix;
  };
}
