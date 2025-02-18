{ config, pkgs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Colloid-Dark";
      package = pkgs.colloid-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      size = 20;
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
    font = {
      size = 11;
      name = "Sans";
    };
  };

  home = {
    pointerCursor = {
      gtk.enable = true;
      size = config.gtk.cursorTheme.size;
      name = config.gtk.cursorTheme.name;
      package = config.gtk.cursorTheme.package;
    };
    packages = with pkgs; [ ulauncher ];
  };
  
  # https://github.com/MrVivekRajan/Hypr-Dots
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "loginctl lock-session";
        text = "Lock [L]";
        keybind = "l";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown [H]";
        keybind = "h";
      }
      {
        label = "logout";
        action = "uwsm stop";
        text = "Logout [O]";
        keybind = "o";
      }
    ];
    style = ''
      window {
          background-color: rgba(0, 0, 0, .5);
          color: #CDD6F4; 
          font-family: CaskaydiaCove NF;
          font-size: 24px;
      }

      button {
          background-color: rgba(1, 121, 111, 0);
          background-position: center;
          background-repeat: no-repeat;
          background-size: 20%;
          border-radius: 20px 20px 20px 20px;
          border: none;
          box-shadow: none;
          color: #FBF1C7;
          margin: 40px;
          text-shadow: none;
          transition: background-color 0.2s ease-in-out;
      }
      button:hover {
          background-color: rgba(213, 196, 161, 0.1);
      }

      #lock {
          background-image: image(url("${./assets/lock.png}"));
      }
      #shutdown {
          background-image: image(url("${./assets/power.png}"));
      }
      #logout {
          background-image: image(url("${./assets/logout.png}"));
      }
    '';
  };

  systemd.user.startServices = "sd-switch";
}
