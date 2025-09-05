# Secrets Management

This directory contains encrypted secrets using agenix. Secrets are encrypted with age and can only be decrypted by authorized keys.

## Available Secrets

- `claudeToken.age` - Anthropic Claude API token
- `openrouterToken.age` - OpenRouter API token
- `tailscaleAuthKey.age` - Tailscale authentication key (used for auto-connect)

## Setting Up Secrets

### 1. Create your age key (if you don't have one):

```bash
age-keygen -o ~/.config/age/keys.txt
```

### 2. Get your public key:

```bash
age-keygen -y ~/.config/age/keys.txt
```

### 3. Update secrets.nix with your public key:

```nix
# secrets.nix
let
  yourPublicKey = "age1..."; # Your age public key here
in
{
  "claudeToken.age".publicKeys = [ yourPublicKey ];
  "openrouterToken.age".publicKeys = [ yourPublicKey ];
}
```

### 4. Create/edit secrets:

```bash
# Edit existing secret
agenix -e claudeToken.age

# Create new secret
echo "your-secret-value" | agenix -e newsecret.age
```

## Adding New Secrets

1. Add the secret file to `secrets.nix`:

```nix
"myNewSecret.age".publicKeys = [ yourPublicKey ];
```

2. Reference it in your module:

```nix
age.secrets.myNewSecret = {
  file = ./secrets/myNewSecret.age;
  # Optional: specify owner/permissions
  mode = "400";
  owner = "mar";
};
```

3. Use the secret in your configuration:

```nix
# In shell config
export MY_SECRET=$(cat ${config.age.secrets.myNewSecret.path})

# Or conditionally
${lib.optionalString (config.age ? secrets && config.age.secrets ? myNewSecret) ''
  export MY_SECRET=$(cat ${config.age.secrets.myNewSecret.path})
''}
```

## Security Notes

- Never commit unencrypted secrets
- The `.age` files are safe to commit (they're encrypted)
- Keep your age private key secure (`~/.config/age/keys.txt`)
- Use different keys for different machines if needed

## Template for New Users

When setting up for a new user, they should:

1. Generate their age key
2. Share their public key with you
3. You add their public key to `secrets.nix`
4. Re-encrypt all secrets with the new key list
5. Commit and push the updated encrypted files
