{ pkgs, config, ... }:

{
    # Install all the packages
    environment.systemPackages = with pkgs; [

        # Rice/desktop
        dwm rofi dmenu feh zsh dunst

        # Command-line tools
        fzf ripgrep newsboat ffmpeg tealdeer exa duf 
        spotify-tui playerctl pass gnupg slop bat endlessh
        libnotify sct update-nix-fetchgit hyperfine zellij
        hunspell hunspellDicts.en-us starship tree unar

        # GUI applications
        firefox mpv nyxt arandr

        # GUI applets
	#nm-applet

        # GUI File readers
        zathura mupdf sxiv

        # Development
        git gcc gnumake python3 
        

        # Other
	bitwarden
	xdotool
	scrot
	nheko
	pavucontrol

        # Language servers for neovim; change these to whatever languages you code in
        # Please note: if you remove any of these, make sure to also remove them from nvim/config/nvim/lua/lsp.lua!!
        rnix-lsp
        sumneko-lua-language-server
    ];
}



