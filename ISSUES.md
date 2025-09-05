# Issues 

## Configuration Tasks

### Issue: Replace placeholder email and user data
**Description:** Update placeholder values like "mar@example.com" with actual user information throughout the configuration
**Files to check:**
- `nix/users/mar/default.nix` - email field
- `nix/hosts/*/default.nix` - any user-specific data
- Git configuration - actual email for commits
**Labels:** configuration, security

### Issue: Properly configure all secrets with agenix
**Description:** Ensure all sensitive data is properly managed through agenix instead of being hardcoded or using placeholders
**Tasks:**
- Document all required secrets
- Create age keys for all systems
- Move any hardcoded API keys to agenix
- Add setup instructions for new users
**Reference:** See `CONFIG_TEMPLATE.md` and `nix/modules/home/secrets/README.md`
**Labels:** security, documentation

### Issue: Configure tmux shell integration
**Description:** Set up tmux with proper shell configuration
**Reference:** https://rycee.gitlab.io/home-manager/options.html#opt-programs.tmux.shell
**Labels:** enhancement, home-manager

### Issue: Fix 1TB NVMe disk recognition
**Description:** Troubleshoot and fix the 1TB NVMe disk that's not being recognized
**Labels:** bug, hardware

### Issue: Set up screenshot program
**Description:** Configure a proper screenshot utility (currently using flameshot)
**Labels:** enhancement, desktop

## Desktop Environment Enhancements

### Issue: Add keyboard shortcuts to sxhkd
**Description:** Configure additional keyboard shortcuts for(the shortcuts can change, only a sugestiong):
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
