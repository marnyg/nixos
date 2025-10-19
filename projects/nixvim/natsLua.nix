{ lib
, buildLuaPackage
, fetchFromGitHub
, lua
, luasocket
, lua-cjson
}:

buildLuaPackage rec {
  pname = "lua-nats";
  version = "0.0.5"; # Update to match the actual version

  src = fetchFromGitHub {
    owner = "DawnAngel";
    repo = "lua-nats";
    rev = "master"; # Or use a specific commit/tag
    sha256 = "sha256-Jmp1lh0cLQ9yeG2AiRBWJ+q9GQM8BrRJ+uvNj8KX+IM=";
  };

  propagatedBuildInputs = [
    luasocket
    lua-cjson
    (buildLuaPackage rec {
      pname = "uuid";
      version = "unstable-2024-01-01";

      src = fetchFromGitHub {
        owner = "Tieske";
        repo = "uuid";
        rev = "master";
        sha256 = "sha256-NM9wYwWZCm1PuqfM/vIvCkP3SoMI2yz+EcY6aFKONEQ=";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/lua/${lua.luaversion}/uuid
        cp src/uuid.lua $out/share/lua/${lua.luaversion}/
        cp -r src/uuid/* $out/share/lua/${lua.luaversion}/uuid/

        runHook postInstall
      '';

      meta = with lib; {
        description = "Pure Lua UUID library";
        homepage = "https://github.com/Tieske/uuid";
        license = licenses.asl20;
      };
    })
  ];

  # No build phase needed for pure Lua
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install Lua modules
    mkdir -p $out/share/lua/${lua.luaversion}
    cp src/nats.lua $out/share/lua/${lua.luaversion}/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Lua client for NATS messaging system";
    homepage = "https://github.com/DawnAngel/lua-nats";
    license = licenses.mit; # Check the actual license
    maintainers = [ ];
    platforms = platforms.all;
  };
}
