{ inputs, config, pkgs, ... }:
let
  display = "eDP-2";
  
  cursorPkg = pkgs.bibata-cursors;
  cursorName = "Bibata-Modern-Ice";
  cursorSize = 24;
in
{
  gtk = {
    enable = true;
    cursorTheme = {
      size = cursorSize;
      name = cursorName;
      package = cursorPkg;
    };
    font = {
      size = 11;
      name = "Ubuntu Sans";
      package = pkgs.ubuntu-sans;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Colloid-Dark";
      package = pkgs.colloid-gtk-theme;
    };
  };

  xdg.dataFile.images.source = ./images;

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = false;
      preload = [ "${config.xdg.dataFile.images.target}/maplestory.png" ];
      wallpaper = [ "eDP-2, ${config.xdg.dataFile.images.target}/maplestory.png" ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { # Dim screen after 5 minutes
          timeout = 300;
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
        }
        { # Turn off keyboard backlight after 5 minutes
          timeout = 300;
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd asus::kbd_backlight set 0";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd asus::kbd_backlight";
        }
        { # Lock computer after 10 minutes
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        { # Turn off screen after 20 minutes
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      image = {
        position = "0, 220";
        border_color = "rgba(0, 0, 0, 0)";
        path = "${config.xdg.dataFile.images.target}/nix-snowflake-colours.png";
      };
      input-field = {
        fade_on_empty = false;
        outline_thickness = 2;
        placeholder_text = "";
        outer_color = "rgba(0, 0, 0, 0.5)";
        inner_color = "rgba(0, 0, 0, 0.5)";
        check_color = "rgb(126, 186, 228)";
        fail_color = "rgb(255, 0, 0)";
        font_color = "rgb(82, 119, 195)";
        position = "0, -220";
        size = "320, 40";
      };
      background = {
        blur_size = 3;
        blur_passes = 3;
        brightness = 0.5;
        path = "screenshot";
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = "${display}, 1920x1200@144, 0x0, 1";
      layerrule = "blur, gtk-layer-shell";

      env = [
        "GTK_THEME, Colloid-Dark"
        "XCURSOR_THEME, ${cursorName}"
        "XCURSOR_SIZE, ${toString cursorSize}"
      ];

      exec-once = [
        "${inputs.hyprpanel.packages.${pkgs.system}.default}/bin/hyprpanel"
        "hyprctl setcursor ${cursorName} ${toString cursorSize}"
      ];

      general = {
        gaps_in = 10;
        gaps_out = 20;
        border_size = 0;
        snap.enabled = true;
        resize_on_border = true;
        "col.active_border" = "rgba(0, 0, 0, 1)";
        "col.inactive_border" = "rgba(0, 0, 0, 1)";
      };

      decoration = {
        rounding = 20;
        blur = {
          size = 3;
          passes = 3;
        };
        shadow = {
          range = 10;
          render_power = 1;
          color = "rgba(0, 0, 0, 1.0)";
          color_inactive = "rgba(0, 0, 0, 0.2)";
        };
      };

      animations = {
        bezier = [
          "jiggle, 0.15, 1.15, 0.50, 1.00"
          "close, 0.00, 0.85, 1.00, 0.85"
        ];
        animation = [
          "windowsIn       , 1, 2, jiggle, popin"
          "windowsMove     , 1, 2, jiggle, slide"
          "workspaces      , 1, 2, jiggle, slide"
          "specialWorkspace, 1, 2, jiggle, slidevert"
          "fadeOut   , 1, 2, close"
          "windowsOut, 1, 2, close, popin"
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

      windowrulev2 = [
        "opacity 0.9 override 0.9 override 0.9, class:kitty"
        "opacity 0.9 override 0.9 override 0.9, class:neovide"
      ];

      "$MOD" = "SUPER";
      "$ENTER" = 36;
      "$SPACE" = 65;

      bind = [
        "$MOD SHIFT,      Q, exit,"
        # "$MOD      , $SPACE, fullscreen,"
        "          ,    F11, fullscreen,"
        "$MOD      ,      F, togglefloating,"
        "$MOD      ,      C, killactive,"
        "$MOD      , $ENTER, exec, kitty"
        "$MOD      ,      L, exec, hyprlock"
        "$MOD      ,      S, exec, rofi -show drun"
        "$MOD      ,      W, exec, rofi -show window"
        "$MOD      ,      B, exec, ${pkgs.brave}/bin/brave"
        "$MOD      ,      E, exec, ${pkgs.nautilus}/bin/nautilus"
 
        "ALT      ,      J, layoutmsg, cyclenext"
        "ALT      ,      K, layoutmsg, cycleprev"
        "ALT      ,      I, layoutmsg, addmaster"
        "ALT      ,      D, layoutmsg, removemaster"
        "ALT SHIFT,      J, layoutmsg, swapnext"
        "ALT SHIFT,      K, layoutmsg, swapprev"
        "ALT SHIFT,      I, layoutmsg, orientationnext"
        "ALT SHIFT,      D, layoutmsg, orientationprev"
        "ALT SHIFT, $ENTER, layoutmsg, swapwithmaster"

        "ALT      ,   S, togglespecialworkspace,"
        "ALT SHIFT,   S, movetoworkspace, special"
        "ALT      , TAB, workspace            , e+1"
        "ALT      ,   1, workspace            , 1"
        "ALT      ,   2, workspace            , 2"
        "ALT      ,   3, workspace            , 3"
        "ALT      ,   4, workspace            , 4"
        "ALT      ,   5, workspace            , 5"
        "ALT SHIFT,   1, movetoworkspacesilent, 1"
        "ALT SHIFT,   2, movetoworkspacesilent, 2"
        "ALT SHIFT,   3, movetoworkspacesilent, 3"
        "ALT SHIFT,   4, movetoworkspacesilent, 4"
        "ALT SHIFT,   5, movetoworkspacesilent, 5"

        ", XF86AudioRaiseVolume , exec, ${pkgs.pamixer}/bin/pamixer -i 10"
        ", XF86AudioLowerVolume , exec, ${pkgs.pamixer}/bin/pamixer -d 10"
        ", XF86AudioMute        , exec, ${pkgs.pamixer}/bin/pamixer -t"
        ", XF86AudioMicMute     , exec, ${pkgs.pamixer}/bin/pamixer --default-source -t"
        ", XF86MonBrightnessUp  , exec, ${pkgs.brightnessctl}/bin/brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-"
        ", XF86KbdBrightnessUp  , exec, ${pkgs.brightnessctl}/bin/brightnessctl -d asus::kbd_backlight set +1"
        ", XF86KbdBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -d asus::kbd_backlight set 1-"
      ];

      bindm = [
        "$MOD, mouse:272, movewindow"
        "$MOD, mouse:273, resizewindow"
      ];
    };
  };
}
