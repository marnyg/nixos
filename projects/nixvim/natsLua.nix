{ lib
, buildLuaPackage
, buildLuarocksPackage
, fetchFromGitHub
, lua
, luasec
, luasocket
, lua-cjson
, basexx
, lua-resty-openssl
}:

buildLuaPackage rec {
  pname = "lua-nats";
  version = "0.0.5-nkey";

  # Use local nats.lua with NKEY support
  src = ./.;

  propagatedBuildInputs = [
    luasocket
    luasec
    lua-cjson
    basexx
    lua-resty-openssl # For ed25519 signing

    # UUID library
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

    # Install Lua modules from local nats.lua
    mkdir -p $out/share/lua/${lua.luaversion}
    cp nats.lua $out/share/lua/${lua.luaversion}/

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
