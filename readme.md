# instruction

``` bash
# to build a flake, run:
nixos-rebuild switch --flake ".#environmet"

# like this for desktop
nixos-rebuild switch --flake ".#mardesk"	
```a


# todo 
- [ ] set up lf https://rycee.gitlab.io/home-manager/options.html#opt-programs.lf.previewer.source
- [ ] set up tmux [https://rycee.gitlab.io/home-manager/options.html#opt-programs.tmux.shell]
- [ ] fix nvim flake to be installed on nixos sytem
- [ ] try using xmonad istead of bspwm
- [ ] fix 1TB nvme disk
- [ ] set up prinscrean program
- [ ] add programs to sxhkd 
``` sh
# screenshot
Print
    flameshot gui    
# scrot ~/Pictures/Screenshots/%Y-%m-%d-%T-screenshot.png && notify-send 'Fullscreen Screenshot taken'
 
# clipboard
super + v
    rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'

# emoji
super + period
    rofi -show emoji -modi emoji
    
# quit
super + q
    rofi -show menu -width 20 -lines 4  -modi "menu:rofi-power-menu --choices=shutdown/reboot/logout/lockscreen"
            
# rofi calc
super + c
    rofi -show calc -modi calc -no-show-match -no-sort

# rofi-wifi-menu
super + i
    rofi-wifi-menu

# rofi bluetooth
super + b
    rofi-bluetooth
    
# rofi mpd 
super + a
    rofi-mpd -a
```
- [ ] make rofi look better
- [ ] look into rofi launcers
    


# inspiration for nixo 
- [ ] a nixos example of how to do a more clean flake  
    https://git.sr.ht/~misterio/nix-config/tree/main/item/flake.nix
- [ ] automate cloud version of nixos with terraform
    https://nixos.org/guides/deploying-nixos-using-terraform.html
- [ ] Integration testing using virtual machines (VMs)
    https://nixos.org/guides/integration-testing-using-virtual-machines.html
- [ ] set up projects using nix-direnv
    https://github.com/nix-community/nix-direnv
- [ ] look into hosting a gitea repository (with pipeline tool. drone?)
    https://xeiaso.net/blog/gitea-release-tool-2020-05-31
    https://www.drone.io/
