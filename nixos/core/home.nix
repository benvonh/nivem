{ inputs, config, pkgs, host, ... }:
let
  displayForHost = {
    fractal = "DP-2";
    zephyrus = "eDP-2";
  };

  display = if builtins.hasAttr host displayForHost then
    builtins.getAttr host displayForHost
  else
    builtins.trace "WARNING: Unknown host to configure for in Hyprland" "";

  cursorPkg = pkgs.bibata-cursors;
  cursorName = "Bibata-Modern-Ice";
  cursorSize = 24;
in
{
  imports = [ ../../home-manager/ben ];

  gtk = {
    enable = true;
    cursorTheme = {
      size = cursorSize;
      name = cursorName;
      package = cursorPkg;
    };
    font = {
      size = 12;
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

  home = {
    pointerCursor = {
      gtk.enable = true;
      size = cursorSize;
      name = cursorName;
      package = cursorPkg;
    };
    packages = with pkgs; [
      # FIXME: Does not work from HyprBar
      grimblast # Helper for screenshots within Hyprland, based on grimshot
      gpu-screen-recorder-gtk # Screen recorder that has minimal impact on system performance by recording a window using the GPU only

      hyprwall # GUI for setting wallpapers with hyprpaper
      hyprpicker # Wlroots-compatible Wayland color picker that does not suck
      # NOTE: Waiting for updates
      hyprlauncher # GUI for launching applications, written in Rust
     (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  xdg.dataFile.assets.source = ./assets;

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = true;
      splash = false;
      preload = [ "${config.xdg.dataFile.assets.target}/maplestory.png" ];
      wallpaper = [ "${display}, ${config.xdg.dataFile.assets.target}/maplestory.png" ];
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
        position = "0, 180";
        border_color = "rgba(0, 0, 0, 0)";
        path = "${config.xdg.dataFile.assets.target}/nix-snowflake-colours.png";
      };
      input-field = {
        fade_on_empty = false;
        outline_thickness = 2;
        placeholder_text = "";
        outer_color = "rgba(0, 0, 0, 0.2)";
        inner_color = "rgba(0, 0, 0, 0.2)";
        check_color = "rgb(126, 186, 228)";
        fail_color = "rgb(255, 0, 0)";
        font_color = "rgb(82, 119, 195)";
        position = "0, -180";
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
      monitor = [
        "${display}, highrr, auto, 1"
        ", preferred, auto, 1"
      ];

      layerrule = [
        "blur, rofi"
        "blur, bar-0"
        "blur, logout_dialog"
        "blur, notifications-window"
      ];

      env = [
        "GTK_THEME, Colloid-Dark"
        "XCURSOR_THEME, ${cursorName}"
        "XCURSOR_SIZE, ${toString cursorSize}"
        "HYPRCURSOR_THEME, ${cursorName}"
        "HYPRCURSOR_SIZE, ${toString cursorSize}"
      ];

      exec-once = [
        "${inputs.hyprpanel.packages.${pkgs.system}.default}/bin/hyprpanel"
        "hyprctl setcursor ${cursorName} ${toString cursorSize}"
      ];

      general = {
        gaps_in = 10;
        gaps_out = 20;
        border_size = 0;
        resize_on_border = true;
      };

      decoration = {
        # NOTE: Floatin hints get rounded, too, which also have borders
        # NOTE: Floating windows (e.g., hints) also get rounded which can look weird
        rounding = 0;
        blur = {
          size = 3;
          passes = 3;
        };
        shadow = {
          range = 20;
          render_power = 2;
          color = "rgba(0, 0, 0, 1.0)";
          color_inactive = "rgba(0, 0, 0, 0.25)";
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

      bind = [
        "     ,    F10, togglefloating,"
        "     ,    F11, fullscreen,"
        "SUPER,      C, killactive,"
        "SUPER, $ENTER, exec, ${pkgs.kitty}/bin/kitty"
        "SUPER,      B, exec, ${pkgs.brave}/bin/brave"
        "SUPER,      I, exec, ${pkgs.neovide}/bin/neovide"
        "SUPER,      F, exec, ${pkgs.nautilus}/bin/nautilus"
        "SUPER,      L, exec, ${pkgs.hyprlock}/bin/hyprlock"
        "SUPER,      [, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun"
        "SUPER,    TAB, exec, ${pkgs.rofi-wayland}/bin/rofi -show window"
 
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

        ", XF86AudioRaiseVolume , exec, ${pkgs.pamixer}/bin/pamixer -i 10"
        ", XF86AudioLowerVolume , exec, ${pkgs.pamixer}/bin/pamixer -d 10"
        ", XF86AudioMute        , exec, ${pkgs.pamixer}/bin/pamixer -t"
        ", XF86AudioMicMute     , exec, ${pkgs.pamixer}/bin/pamixer --default-source -t"
      ];

      bindm = [
        "$SUPER, mouse:272, movewindow"
        "$SUPER, mouse:273, resizewindow"
      ];
    };
  };

  systemd.user.startServices = "sd-switch";
}
