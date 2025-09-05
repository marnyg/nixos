# Systems configuration flake module
{ ... }:

{
  # Define supported systems
  systems = [
    "x86_64-linux" # Linux x86_64
    "aarch64-linux" # Linux ARM64
    "aarch64-darwin" # macOS ARM64 (Apple Silicon)
  ];
}
