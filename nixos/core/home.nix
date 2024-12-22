{ inputs, config, pkgs, host, ... }:
let
  themePkg = pkgs.colloid-gtk-theme;
  themeName = "Colloid-Dark";

  iconPkg = pkgs.papirus-icon-theme;
  iconName = "Papirus-Dark";

  cursorPkg = pkgs.bibata-cursors;
  cursorName = "Bibata-Modern-Ice";
  cursorSize = 20;
in
{
  systemd.user.startServices = "sd-switch";

  ##########################################
  #                 THEMES                 #
  ##########################################
  gtk = {
    enable = true;
    theme = {
      name = themeName;
      package = themePkg;
    };
    iconTheme = {
      name = iconName;
      package = iconPkg;
    };
    cursorTheme = {
      size = cursorSize;
      name = cursorName;
      package = cursorPkg;
    };
    font = {
      size = 11;
      name = "Sans";
    };
  };

  home = {
    pointerCursor = {
      gtk.enable = true;
      size = cursorSize;
      name = cursorName;
      package = cursorPkg;
    };
    packages = with pkgs; [
      # TODO: Help create a Home Manager module for it?
      ulauncher
   ] ++ (if host == "fractal" then
   [
     python3Packages.gpustat
   ] else []
   );
  };

  # https://github.com/MrVivekRajan/Hypr-Dots
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "  Lock";
        keybind = "l";
        circular = true;
      }
      {
        label = "logout";
        action = "hyprctl dispatch exit";
        text = " Logout  ";
        keybind = "m";
        circular = true;
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = " Suspend ";
        keybind = "s";
        circular = true;
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown ";
        keybind = "d";
        circular = true;
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = " Reboot  ";
        keybind = "r";
        circular = true;
      }
    ];
    style = ''
      window {
          font-family: CaskaydiaCove NF, monospace;
          font-size: 12pt;
          color: #cdd6f4; 
          background-color: rgba(0, 0, 0, .5);
      }

      button {
          background-repeat: no-repeat;
          background-position: center;
          background-size: 60%;
          border: none;
          color: #fbf1c7;
          text-shadow: none;
          border-radius: 20px 20px 20px 20px;
          background-color: rgba(1, 121, 111, 0);
          margin: 5px;
          transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
      }

      button:hover {
          background-color: rgba(213, 196, 161, 0.1);
      }

      #lock {
          background-image: image(url("${./assets/icons/lock.png}"));
          background-size: 70%;
      }
      #lock:focus {
          background-image: image(url("${./assets/icons/lock-hover.png}"));
      }

      #logout {
          background-image: image(url("${./assets/icons/logout.png}"));
      }
      #logout:focus {
          background-image: image(url("${./assets/icons/logout-hover.png}"));
      }

      #suspend {
          background-image: image(url("${./assets/icons/sleep.png}"));
      } 
      #suspend:focus {
          background-image: image(url("${./assets/icons/sleep-hover.png}"));
      }

      #shutdown {
          background-image: image(url("${./assets/icons/power.png}"));
      }
      #shutdown:focus {
          background-image: image(url("${./assets/icons/power-hover.png}"));
      }

      #reboot {
          background-image: image(url("${./assets/icons/restart.png}"));
      }
      #reboot:focus {
          background-image: image(url("${./assets/icons/restart-hover.png}"));
      }
    '';
  };

  # xdg.dataFile.wlogout-icons.source = ./assets/icons;

  ############################################
  #                 HYPRLAND                 #
  ############################################
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

      monitor = let
        displayForHost = {
          zephyrus = "eDP-2";
          fractal = "DP-2";
        };
        display = if builtins.hasAttr host displayForHost then
          builtins.getAttr host displayForHost
          else throw "[nivem] unknown host ${host} for display";
      in [
        # display, resolution, position, scale
        "${display}, highrr, auto, 1"
        ", preferred, auto, 1"
      ];

      layerrule = [
        "blur, rofi"
        "blur, bar-0"
        "blur, logout_dialog"
      ];

      env = [
        "TERM, kitty"
        "EDITOR, nvim"
        "GTK_THEME, Colloid-Dark"
        "XCURSOR_THEME, ${cursorName}"
        "XCURSOR_SIZE, ${toString cursorSize}"
        "HYPRCURSOR_THEME, ${cursorName}"
        "HYPRCURSOR_SIZE, ${toString cursorSize}"
      ];

      exec-once = [
        "ulauncher"
        "hyprctl setcursor ${cursorName} ${toString cursorSize}"
      ];

      general = {
        gaps_in = 10;
        gaps_out = 20;
        border_size = 0;
        resize_on_border = true;
      };

      decoration = {
        rounding = 0;
        blur = {
          size = 3;
          passes = 3;
          noise = 0.1;
        };
        shadow = {
          range = 20;
          render_power = 1;
          color = "rgba(0,0,0, 1.0)";
          color_inactive = "rgba(0,0,0, 0.5)";
        };
      };

      animations = {
        bezier = [
          "jiggle, 0.15, 1.15, 0.50, 1.00"
          "close, 0.00, 0.85, 1.00, 0.85"
        ];
        animation = [
          # name, on/off, speed, curve [,style]
          "windowsIn  , 1, 3, jiggle, slide"
          "windowsMove, 1, 3, jiggle, slide"
          "workspaces , 1, 3, jiggle, slidefade"
          "windowsOut , 1, 3,  close, slide"
          "fadeOut    , 1, 3,  close"
        ];
      };

      input = {
        scroll_method = "2fg";
        touchpad.natural_scroll = true;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_min_speed_to_force = 20;
      };

      misc = {
        vrr = 1;
        focus_on_activate = true;
        disable_autoreload = true;
        disable_hyprland_logo = true;
        key_press_enables_dpms = true;
        mouse_move_enables_dpms = true;
        new_window_takes_over_fullscreen = 2;
      };

      dwindle = {
        pseudotile = true;
        force_split = 2;
      };

      windowrulev2 = [
        "opacity 0.9 override 0.9 override 0.9, class:kitty"
        "opacity 0.9 override 0.9 override 0.9, class:neovide"
      ];

      "$ENTER" = 36;
      "$SPACE" = 65;

      bind = let
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        wallpaper = pkgs.writeShellApplication {
          runtimeInputs = [ pkgs.eza ];
          name = "wallpaper";
          text = let notify = msg: "notify-send nivem \"${msg}\""; in ''
            if [[ $# -ne 1 ]]; then
              ${notify "Expected an argument but got $#"}
              exit 1
            fi
            
            wallpapers=("$1"/*)

            if [[ ''${#wallpapers[@]} -eq 0 ]]; then
              ${notify "Got an empty directory $1"}
              exit 1
            fi

            selection=$((RANDOM%''${#wallpapers[@]}))

            ${pkgs.swww}/bin/swww img \
              --transition-duration 1 \
              --transition-type grow \
              --transition-fps 144 \
              "''${wallpapers[selection]}"

            code=$?

            if [[ $code -ne 0 ]]; then
              ${notify "Got exit code $code from swww while changing wallpaper"}
              exit 1
            fi
          '';
        };
      in [

        "     ,    F10, togglefloating,"
        "     ,    F11, fullscreen,"
        "SUPER,      Q, killactive,"
        "SUPER,      T, exec, kitty"
        "SUPER,      B, exec, brave"
        "SUPER,      N, exec, neovide"
        "SUPER,      E, exec, nautilus"
        "SUPER,      L, exec, wlogout -b 5"
        "SUPER, $ENTER, exec, ulauncher-toggle"

        "SUPER,      A, exec, ${wallpaper}/bin/wallpaper ${../../wallpapers/anime}"
        "SUPER,      H, exec, ${wallpaper}/bin/wallpaper ${../../wallpapers/mountain}"

        # TODO: How to navigate dwindle layout
        # TODO: Is it possible to expand/shrink windows
 
        # master layout key binding
        # "SUPER      ,      J, layoutmsg, cyclenext"
        # "SUPER      ,      K, layoutmsg, cycleprev"
        # "SUPER      ,      I, layoutmsg, addmaster"
        # "SUPER      ,      D, layoutmsg, removemaster"
        # "SUPER SHIFT,      J, layoutmsg, swapnext"
        # "SUPER SHIFT,      K, layoutmsg, swapprev"
        # "SUPER SHIFT,      I, layoutmsg, orientationnext"
        # "SUPER SHIFT,      D, layoutmsg, orientationprev"
        # "SUPER SHIFT, $ENTER, layoutmsg, swapwithmaster"

        # scratch pad key binding
        # "SUPER      ,   S, togglespecialworkspace,"
        # "SUPER SHIFT,   S, movetoworkspace, special"

        "ALT        ,    TAB,             workspace, e+1"
        "SUPER      ,      1,             workspace, 1"
        "SUPER      ,      2,             workspace, 2"
        "SUPER      ,      3,             workspace, 3"
        "SUPER      ,      4,             workspace, 4"
        "SUPER      ,      5,             workspace, 5"
        "SUPER SHIFT,      1, movetoworkspacesilent, 1"
        "SUPER SHIFT,      2, movetoworkspacesilent, 2"
        "SUPER SHIFT,      3, movetoworkspacesilent, 3"
        "SUPER SHIFT,      4, movetoworkspacesilent, 4"
        "SUPER SHIFT,      5, movetoworkspacesilent, 5"
        "SUPER SHIFT, $ENTER,             layoutmsg, swapsplit"

        ", XF86AudioRaiseVolume , exec, ${pamixer} -i 10"
        ", XF86AudioLowerVolume , exec, ${pamixer} -d 10"
        ", XF86AudioMute        , exec, ${pamixer} -t"
        ", XF86AudioMicMute     , exec, ${pamixer} --default-source -t"
      ];

      bindm = [
        "ALT, mouse:272, movewindow"
        "ALT, mouse:273, resizewindow"
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}
