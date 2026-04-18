{ ... }:
{
  perSystem = { pkgs, ... }:
    let
      vmDir = "$HOME/.local/share/windows-vm";
    in
    {
      packages.windowsVM = pkgs.writeShellApplication {
        name = "windowsVM";
        runtimeInputs = with pkgs; [ quickemu quickgui cdrtools ];
        text = ''
          VM_DIR="${vmDir}"
          VM_SUBDIR="$VM_DIR/windows-11"
          CONF="$VM_DIR/windows-11.conf"
          mkdir -p "$VM_SUBDIR"
          cd "$VM_DIR"

          # Build unattended.iso if XML exists but ISO doesn't
          ensure_unattended_iso() {
            if [ -d "$VM_SUBDIR/unattended" ] && [ ! -f "$VM_SUBDIR/unattended.iso" ]; then
              echo "Building unattended.iso..."
              mkisofs -quiet -J -o "$VM_SUBDIR/unattended.iso" "$VM_SUBDIR/unattended/"
            fi
          }

          generate_conf() {
            ISO=$(find "$VM_SUBDIR" -maxdepth 1 -name '*.iso' -not -name 'virtio-win*' -not -name 'unattended*' | head -1)
            if [ -z "$ISO" ]; then
              echo "No Windows ISO found in $VM_SUBDIR"
              echo "Download from: https://www.microsoft.com/en-us/software-download/windows11"
              echo "Save the .iso to: $VM_SUBDIR/"
              return 1
            fi
            ISO_NAME=$(basename "$ISO")
            cat > "$CONF" << EOF
          guest_os="windows"
          disk_img="windows-11/disk.qcow2"
          iso="windows-11/$ISO_NAME"
          fixed_iso="windows-11/virtio-win.iso"
          tpm="on"
          secureboot="off"
          cpu_cores="8"
          ram="16G"
          disk_size="128G"
          EOF
            echo "Generated config: $CONF"
          }

          case "''${1:-}" in
            setup)
              echo "Downloading Windows 11 via quickget..."
              quickget windows 11
              # If quickget couldn't download the ISO, try generating conf from manual download
              if [ ! -f "$CONF" ]; then
                echo ""
                echo "Checking for manually downloaded ISO..."
                generate_conf || true
              fi
              ensure_unattended_iso
              echo ""
              echo "Default credentials: Quickemu / quickemu"
              echo "Run 'nix run .#windowsVM' to start the VM."
              ;;
            down)
              PIDFILE="$VM_SUBDIR/windows-11.pid"
              if [ -f "$PIDFILE" ]; then
                PID=$(cat "$PIDFILE")
                if kill -0 "$PID" 2>/dev/null; then
                  echo "Sending ACPI shutdown to VM (pid $PID)..."
                  kill "$PID"
                  echo "VM shutting down."
                else
                  echo "VM is not running (stale pid file)."
                  rm -f "$PIDFILE"
                fi
              else
                echo "VM is not running."
              fi
              ;;
            kill)
              PIDFILE="$VM_SUBDIR/windows-11.pid"
              if [ -f "$PIDFILE" ]; then
                PID=$(cat "$PIDFILE")
                if kill -0 "$PID" 2>/dev/null; then
                  echo "Force killing VM (pid $PID)..."
                  kill -9 "$PID"
                  rm -f "$PIDFILE" "$VM_SUBDIR/.lock"
                  echo "VM killed."
                else
                  echo "VM is not running (stale pid file)."
                  rm -f "$PIDFILE" "$VM_SUBDIR/.lock"
                fi
              else
                echo "VM is not running."
              fi
              ;;
            status)
              PIDFILE="$VM_SUBDIR/windows-11.pid"
              if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
                echo "VM is running (pid $(cat "$PIDFILE"))"
              else
                echo "VM is not running."
              fi
              ;;
            gui)
              quickgui
              ;;
            help|--help|-h)
              echo "Usage: windowsVM [command]"
              echo ""
              echo "Commands:"
              echo "  (none)    Start the VM"
              echo "  setup     Download Windows 11 ISO and configure"
              echo "  down      Graceful shutdown (SIGTERM)"
              echo "  kill      Force kill the VM"
              echo "  status    Check if the VM is running"
              echo "  gui       Open quickgui"
              ;;
            *)
              # Generate conf if missing but ISO exists
              if [ ! -f "$CONF" ]; then
                generate_conf || exit 1
              fi
              ensure_unattended_iso
              echo "Starting: $CONF"
              echo "Default credentials: Quickemu / quickemu"
              quickemu --vm "$CONF"
              ;;
          esac
        '';
      };
    };
}
