{
  perSystem = { pkgs, lib, ... }: {
    # This adds a `self.packages.default`
    process-compose."proc-compose" =
      let
        port = 8213;
        dataFile = "data.sqlite";
      in
      {
        settings = {
          environment = {
            SQLITE_WEB_PASSWORD = "demo";
          };

          processes = {
            # Print a pony every 2 seconds, because why not.
            ponysay.command = ''
              while true; do
                ${lib.getExe pkgs.cowsay} "Enjoy our sqlite-web demo!"
                sleep 2
              done
            '';


            # Run sqlite-web on the local chinook database.
            sqlite-web = {
              command = ''
                ${pkgs.sqlite-web}/bin/sqlite_web \
                  --password \
                  --port ${builtins.toString port} "${dataFile}"
              '';
              # The 'depends_on' will have this process wait until the above one is completed.
              readiness_probe.http_get = {
                host = "localhost";
                inherit port;
              };
            };

            # If a process is named 'test', it will be ignored. But a new
            # flake check will be created that runs it so as to test the
            # other processes.
            test = {
              command = pkgs.writeShellApplication {
                name = "sqlite-web-test";
                runtimeInputs = [ pkgs.curl ];
                text = ''
                  curl -v http://localhost:${builtins.toString port}/
                '';
              };
              depends_on."sqlite-web".condition = "process_healthy";
            };
          };
        };
      };
  };
}
