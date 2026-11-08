# jetkvm-mcp — MCP server that drives a PC through a JetKVM (screenshots,
# keyboard/mouse HID, virtual media, ATX power) over one WebRTC connection
# to stock firmware. Plain Python scripts, no packaging upstream, so we
# wrap server.py with a python env that has its requirements.txt deps.
# Upstream: https://github.com/shvartzj1/jetkvm-mcp
#
# Config via env (set per MCP client, see modules.my.pi-agent.mcpServers):
#   JETKVM_URL              http://<device>   (required)
#   JETKVM_PASSWORD         omit in noPassword mode
#   JETKVM_VERIFY_TLS       default false (self-signed)
#   JETKVM_KEYBOARD_LAYOUT  layout of the *target* OS: us|uk|de|fr
{ lib
, stdenvNoCC
, fetchFromGitHub
, python3
, makeWrapper
}:

let
  python = python3.withPackages (ps: with ps; [
    mcp
    aiortc
    httpx
    websockets
    av
    pillow
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "jetkvm-mcp";
  version = "0-unstable-2026-09-23";

  src = fetchFromGitHub {
    owner = "shvartzj1";
    repo = "jetkvm-mcp";
    rev = "49c72cd4b5412325ebb3f87dc45ee708edb879f2";
    hash = "sha256-G6GqnvUI/XKuH54Hh/g4T/OeZOHpLtLFObUdCUYG7EU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/jetkvm-mcp $out/bin
    cp -r jetkvm server.py smoke_test.py $out/share/jetkvm-mcp/

    makeWrapper ${python}/bin/python $out/bin/jetkvm-mcp \
      --add-flags "$out/share/jetkvm-mcp/server.py"
    # Connectivity check: connects, holds the stream open, saves a few
    # screenshots. Needs JETKVM_URL in the environment.
    makeWrapper ${python}/bin/python $out/bin/jetkvm-mcp-smoke-test \
      --add-flags "$out/share/jetkvm-mcp/smoke_test.py"
    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP server that lets an AI see and drive a machine through a JetKVM";
    homepage = "https://github.com/shvartzj1/jetkvm-mcp";
    license = licenses.mit;
    mainProgram = "jetkvm-mcp";
    platforms = platforms.unix;
  };
}
