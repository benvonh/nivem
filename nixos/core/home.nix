{ inputs, pkgs, host, ... }:
let
  displayForHost = {
    fractal = "DP-2";
    zephyrus = "eDP-2";
  };

  display = if builtins.hasAttr host displayForHost then
    builtins.getAttr host displayForHost
  else throw ''
    nivem unknown host '${host}' for display
    (see ./nixos/core/home.nix)
  '';

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

      # NOTE: Waiting to be added to nixpkgs
      inputs.hyprpanel.packages.${pkgs.system}.default
     (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  # FIXME: HyprPanel can set wallpaper?
  # services.hyprpaper = {
  #   enable = true;
  #   settings = {
  #     ipc = true;
  #     splash = false;
  #     preload = [ "${./assets/maplestory.png}" ];
  #     wallpaper = [ "${display}, ${./assets/maplestory.png}" ];
  #   };
  # };

  #########################################
  #                 HYPR*                 #
  #########################################
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { # Lock computer after 10 minutes
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        { # Turn off screen after 20 minutes
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ] ++ (let bctl = "${pkgs.brightnessctl}/bin/brightnessctl";
      in if host == "zephyrus" then
      [
        { # Dim laptop screen after 5 minutes
          timeout = 300;
          on-timeout = "${bctl} -s set 10";
          on-resume = "${bctl} -r";
        }
        { # Turn off keyboard backlight after 5 minutes
          timeout = 300;
          on-timeout = "${bctl} -sd asus::kbd_backlight set 0";
          on-resume = "${bctl} -rd assus::kbd_backlight";
        }
      ] else []
      );
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      background = {
        blur_size = 1;
        blur_passes = 2;
        path = "${./assets/5cm-per-second.jpg}";
      };
      label = {
        text = "$TIME";
        font_size = 96;
        font_family = "Serif Bold";
        color = "rgb(255,231,242)";
        shadow_boost = 4.8;
        shadow_passes = 1;
        position = "0, 0";
        halign = "center";
        valign = "center";
      };
      input-field = {
        size = "225, 45";
        position = "0, 135";
        fail_text = "INCORRECT";
        placeholder_text = "LOCKED";
        font_family = "Serif Bold";
        font_color = "rgb(0,0,0)";
        check_color = "rgb(242,255,231)";
        inner_color = "rgb(166,142,153)";
        outline_thickness = 0;
        shadow_passes = 1;
        dots_size = 0.3;
        halign = "center";
        valign = "bottom";
      };
    };
  };

  ############################################
  #                 HYPRLAND                 #
  ############################################
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [
        ", preferred, auto, 1"
        "${display}, highrr, auto, 1"
      ];

      layerrule = [
        "blur, rofi"
        "blur, bar-0"
        "blur, logout_dialog"
        "blur, notifications-window"
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
        "hyprpanel"
        "hyprctl setcursor ${cursorName} ${toString cursorSize}"
      ];

      general = {
        gaps_in = 10;
        gaps_out = 20;
        border_size = 0;
        resize_on_border = true;
        # "col.active_border" = "rgb(000000)";
        # "col.inactive_border" = "rgb(000000)";
      };

      decoration = {
        rounding = 0;
        blur = {
          size = 3;
          passes = 3;
        };
        shadow = {
          range = 20;
          # offset = "2, 2";
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
          "windowsIn  , 1, 3, jiggle, popin"
          "windowsMove, 1, 3, jiggle, slide"
          "workspaces , 1, 3, jiggle, slide"
          "fadeOut    , 1, 3, close"
          "windowsOut , 1, 3, close, popin"
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
          text = let
            notify = msg: "notify-send nivem \"${msg}\"";
          in ''
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
            
            ${notify "Changing wallpaper..."}

            ${pkgs.swww}/bin/swww img \
              --transition-duration 2 \
              --transition-type grow \
              --transition-fps 144 \
              "''${wallpapers[selection]}"
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
        # TODO: Change to wlogout
        "SUPER,      L, exec, hyprlock"
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
