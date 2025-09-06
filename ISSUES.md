# Issues and Improvements

## High Priority Tasks

### Hardware Issues

#### Setup 1TB NVMe disk (KINGSTON SFYRS1000G)

**Description:** The 1TB NVMe drive is detected but needs to be partitioned, formatted, and mounted
**Current Status:**

- ✅ Drive detected as `/dev/nvme0n1` (931.5G KINGSTON SFYRS1000G)
- ❌ Not partitioned
- ❌ Not formatted
- ❌ Not mounted

**Steps needed:**

1. Partition the drive: `sudo parted /dev/nvme0n1 mklabel gpt mkpart primary ext4 0% 100%`
2. Format: `sudo mkfs.ext4 /dev/nvme0n1p1`
3. Get UUID: `blkid /dev/nvme0n1p1`
4. Add to hardware.nix with appropriate mount point
5. Rebuild NixOS configuration

## Medium Priority Improvements

### Code Organization

#### Review lib.mkDefault usage

**Issue:** Found 100+ instances of lib.mkDefault, many unnecessary
**Action:** Only use mkDefault where host-level overrides are expected

```nix
# In profiles
modules.my = {
  # Required for profile
  firefox.enable = true;

  # Optional (overrideable by hosts)
  qutebrowser.enable = lib.mkDefault true;
}
```

#### Hardware profiles

**Proposed:** Create hardware profiles for common patterns:

- nvidia.nix - NVIDIA GPU configuration
- audio.nix - Audio setup (pipewire, etc.)
- bluetooth.nix - Bluetooth configuration
- laptop-power.nix - Power management for laptops

## Low Priority / Nice to Have

### Desktop Environment Enhancements

#### Configure screenshot utility

**Current:** Using flameshot
**Task:** Ensure proper keybinding configuration

#### Add keyboard shortcuts

Configure additional shortcuts for:

- Screenshot (Print) - flameshot gui
- Clipboard manager (super + v)
- Power menu (super + q)
- Other utility shortcuts as needed

#### Improve rofi appearance

**Task:** Apply custom theme for better appearance

### Development Environment

#### Configure tmux shell integration

**Reference:** https://rycee.gitlab.io/home-manager/options.html#opt-programs.tmux.shell

### Future Considerations

#### Add VM integration testing

**Reference:** https://nixos.org/guides/integration-testing-using-virtual-machines.html

#### Automate cloud NixOS with Terraform

**Reference:** https://nixos.org/guides/deploying-nixos-using-terraform.html

#### Self-host Git repository

**Option:** Gitea with CI/CD pipeline
**References:**

- https://xeiaso.net/blog/gitea-release-tool-2020-05-31
- https://www.drone.io/
