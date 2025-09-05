# GitHub Issues to Create

These TODOs were extracted from the README and should be created as GitHub issues:

## Configuration Tasks

### Issue: Configure lf file manager previewer
**Description:** Set up lf (terminal file manager) with proper preview functionality
**Reference:** https://rycee.gitlab.io/home-manager/options.html#opt-programs.lf.previewer.source
**Labels:** enhancement, home-manager

### Issue: Configure tmux shell integration
**Description:** Set up tmux with proper shell configuration
**Reference:** https://rycee.gitlab.io/home-manager/options.html#opt-programs.tmux.shell
**Labels:** enhancement, home-manager

### Issue: Fix nvim flake system installation
**Description:** Fix neovim flake to be properly installed on NixOS system level
**Labels:** bug, nixos

### Issue: Migrate from bspwm to xmonad
**Description:** Try using xmonad as the primary window manager instead of bspwm
**Labels:** enhancement, desktop

### Issue: Fix 1TB NVMe disk recognition
**Description:** Troubleshoot and fix the 1TB NVMe disk that's not being recognized
**Labels:** bug, hardware

### Issue: Set up screenshot program
**Description:** Configure a proper screenshot utility (currently using flameshot)
**Labels:** enhancement, desktop

## Desktop Environment Enhancements

### Issue: Add keyboard shortcuts to sxhkd
**Description:** Configure additional keyboard shortcuts for:
- Screenshot (Print key) - flameshot gui
- Clipboard manager (super + v) - rofi clipboard
- Emoji picker (super + period) - rofi emoji
- Power menu (super + q) - rofi power menu
- Calculator (super + c) - rofi calc
- WiFi menu (super + i) - rofi-wifi-menu
- Bluetooth (super + b) - rofi-bluetooth
- MPD control (super + a) - rofi-mpd
**Labels:** enhancement, desktop, keybindings

### Issue: Improve rofi appearance
**Description:** Make rofi launcher look better with custom theme
**Labels:** enhancement, desktop, ui

### Issue: Research rofi launchers
**Description:** Look into additional rofi launchers for improved functionality
**Labels:** research, desktop

## Infrastructure & Automation

### Issue: Clean flake structure inspiration
**Description:** Review and potentially adopt patterns from https://git.sr.ht/~misterio/nix-config/tree/main/item/flake.nix
**Labels:** refactor, architecture

### Issue: Automate cloud NixOS with Terraform
**Description:** Set up automated cloud deployment of NixOS using Terraform
**Reference:** https://nixos.org/guides/deploying-nixos-using-terraform.html
**Labels:** enhancement, infrastructure

### Issue: Add VM integration testing
**Description:** Set up integration testing using virtual machines
**Reference:** https://nixos.org/guides/integration-testing-using-virtual-machines.html
**Labels:** testing, ci/cd

### Issue: Configure nix-direnv for projects
**Description:** Set up project-specific environments using nix-direnv
**Reference:** https://github.com/nix-community/nix-direnv
**Labels:** enhancement, development

### Issue: Self-host Git repository
**Description:** Look into hosting a Gitea repository with CI/CD pipeline (possibly Drone)
**References:** 
- https://xeiaso.net/blog/gitea-release-tool-2020-05-31
- https://www.drone.io/
**Labels:** infrastructure, self-hosting

## How to Create These Issues

1. Go to your GitHub repository
2. Navigate to the Issues tab
3. Click "New Issue"
4. Copy the title and description from each issue above
5. Add the suggested labels
6. Optionally add milestones or assign to yourself

You can also use GitHub CLI:
```bash
gh issue create --title "Configure lf file manager previewer" \
  --body "Set up lf (terminal file manager) with proper preview functionality\nReference: https://rycee.gitlab.io/home-manager/options.html#opt-programs.lf.previewer.source" \
  --label "enhancement,home-manager"
```