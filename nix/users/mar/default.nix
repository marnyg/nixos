# User metadata and preferences for 'mar'
{
  username = "mar";
  fullName = "Marius Nygård";
  email = "mar@example.com"; # Update with actual email

  # User preferences
  preferences = {
    shell = "fish";
    editor = "nixvim";
    terminal = "ghostty";
    browser = "firefox";
  };

  # Profile selections for different environments
  profiles = {
    wsl = [ "developer" "minimal" ];
    desktop = [ "developer" "desktop" ];
    laptop = [ "developer" "desktop" ];
  };
}
