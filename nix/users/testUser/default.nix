# User metadata and preferences for 'testUser'
{
  username = "testUser";
  fullName = "Test User";
  email = "test@example.com";

  # User preferences
  preferences = {
    shell = "bash";
    editor = "vim";
    terminal = "kitty";
    browser = "firefox";
  };

  # Profile selections for different environments
  profiles = {
    wsl = [ "minimal" ];
    desktop = [ "minimal" ];
    laptop = [ "minimal" ];
  };
}
