# Configuration Template

This file lists all the placeholder values that should be customized when using this configuration.

## User Information

### File: `nix/users/mar/default.nix`
Replace these values with your actual information:
```nix
{
  username = "mar";           # Your username
  fullName = "Marius Nygård"; # Your full name
  email = "mar@example.com";  # Your actual email (currently placeholder)
}
```

### SSH Keys
Add your SSH public keys in `nix/users/mar/system.nix`:
```nix
openssh.authorizedKeys.keys = [
  "ssh-rsa AAAAB3..." # Your SSH public key
];
```

## Secrets Setup

### Required Secrets
These secrets need to be created if you use certain features:

1. **API Tokens** (for AI tools):
   - `claudeToken.age` - Anthropic Claude API
   - `openrouterToken.age` - OpenRouter API

See `nix/modules/home/secrets/README.md` for setup instructions.

## Git Configuration

### File: `nix/modules/home/programs/git.nix`
Update with your information:
```nix
userName = "Your Name";
userEmail = "your.email@example.com";
signing.key = "YOUR_GPG_KEY_ID"; # If using commit signing
```

## Host-Specific Settings

### Network Configuration
Update hostnames in host files:
- `nix/hosts/desktop/default.nix`
- `nix/hosts/laptop/default.nix`
- `nix/hosts/wsl/default.nix`

### Hardware Configuration
- Review and update hardware configs for your actual hardware
- GPU settings (NVIDIA/AMD/Intel)
- Display configuration in Hyprland

## Optional Services

### Syncthing
If using Syncthing, update device IDs and folder paths in:
- `nix/modules/nixos/services/syncthing.nix`

### Tailscale
Configure your Tailscale authentication if using it:
- `nix/modules/nixos/services/tailscale.nix`

## Auto-upgrade Settings

### File: `nix/hosts/desktop/default.nix`
Update the flake URL for auto-upgrades:
```nix
system.autoUpgrade = {
  enable = true;
  flake = "github:YOUR_USERNAME/YOUR_REPO#desktop"; # Update this
};
```

## Checklist for New Users

- [ ] Update user information in `nix/users/mar/default.nix`
- [ ] Add SSH public keys
- [ ] Set up age encryption keys
- [ ] Create required secret files
- [ ] Update git configuration
- [ ] Customize hardware settings
- [ ] Configure optional services
- [ ] Update auto-upgrade flake URL
- [ ] Remove/update example comments

## Security Reminders

- Never commit real passwords or tokens
- Use agenix for all secrets
- Review all placeholder values before deploying
- Keep your age private key secure