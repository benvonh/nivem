{ inputs, config, pkgs, osConfig, ... }:
let
  host = osConfig.networking.hostName;

  lockArtSize = "80";

  lockMusicArtPath = "/tmp/lock-screen-art.png";

  customLockScript = pkgs.writeShellApplication {
    runtimeInputs = with pkgs; [ hyprlock playerctl imagemagick ];
    name = "lock";
    text = ''
      if playerctl metadata; then
        artUrl=$(playerctl metadata mpris:artUrl)
        artPath=''${artUrl#file://}
        magick "$artPath" -resize ${lockArtSize}x${lockArtSize}^ \
          -gravity center -extent ${lockArtSize}x${lockArtSize} ${lockMusicArtPath}
      fi

      exec hyprlock
    '';
  };

  lockTextScript = pkgs.writeShellApplication {
    runtimeInputs = with pkgs; [ playerctl curl ];
    name = "text";
    text = ''
      if playerctl metadata &> /dev/null; then
        playerctl metadata xesam:title
      else
        curl -s 'wttr.in/Brisbane?format=3'
      fi
    '';
  };
in
{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${customLockScript}/bin/lock";
        unlock_cmd = "rm -f ${lockMusicArtPath}";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        before_sleep_cmd = "loginctl lock-session";
      };
      listener = [
        { # Lock computer after 10 minutes
          timeout = 10 * 60;
          on-timeout = "loginctl lock-session";
        }
        { # Turn off screen after 30 minutes
          timeout = 30 * 60;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        { # Suspend computer after 1 hour
          timeout = 1 * 60 * 60;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  ########################################
  #                 LOCK                 #
  ########################################
  programs.hyprlock = {
    enable = true;
    settings = {
      # Lock Wallpaper
      background.path = "${./assets/5cm-per-second.jpg}";
      label = [
        { # Lock Icon
          text = "<span>  </span>";
          color = "rgb(255,231,242)";
          halign = "center";
          valign = "top";
          position = "0, -180";
          font_size = 39;
          font_family = "JetBrainsMono NFP";
          shadow_boost = 4.8;
          shadow_passes = 1;
        }
        { # Display Time
          text = "$TIME";
          color = "rgb(255,231,242)";
          halign = "center";
          valign = "center";
          position = "0, 0";
          font_size = 112;
          font_family = "Serif Bold";
          shadow_boost = 9;
          shadow_passes = 1;
        }
        { # Widget Text
          text = "cmd[update:100000] ${lockTextScript}/bin/text";
          color = "rgb(255,231,242)";
          halign = "center";
          valign = "bottom";
          position = "0, 20";
          font_size = 16;
          font_family = "JetBrainsMono NFP";
          shadow_size = 1;
          shadow_boost = 9;
          shadow_passes = 1;
        }
      ];
      # Input Password
      input-field = {
        size = "220, 40";
        halign = "center";
        valign = "bottom";
        position = "0, 270";
        dots_size = 0.35;
        fail_text = "";
        fail_color = "rgb(255,57,68)";
        check_color = "rgb(231,255,242)";
        inner_color = "rgb(255,231,242)";
        shadow_size = 1;
        shadow_boost = 9;
        shadow_passes = 1;
        placeholder_text = "";
        outline_thickness = 0;
      };
      # Music Art
      image = {
        size = lockArtSize;
        path = lockMusicArtPath;
        halign = "center";
        valign = "bottom";
        position = "0, 64";
        rounding = 10;
        border_size = 0;
        shadow_size = 1;
        shadow_boost = 9;
        shadow_passes = 1;
      };
    };
  };

  #########################################
  #                 PANEL                 #
  #########################################
  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    hyprland.enable = true;
    overwrite.enable = true;
    overlay.enable = true;

    theme = "gruvbox";

    layout = {
      "bar.layouts" =
        if host == "fractal" then {
          "0" = {
            left = [ "dashboard" "workspaces" ];
            middle = [ "media" ];
            right = [ "systray" "volume" "clock" "notifications" ];
          };
        }
        else if host == "zephyrus" then {
          "0" = {
            left = [ "dashboard" "workspaces" "storage" "ram" "cpu" "battery" ];
            middle = [ "media" ];
            right = [ "volume" "bluetooth" "clock" "systray" "notifications" "power" ];
          };
          "*" = {
            left = [ "workspaces" "storage" "ram" "cpu" "battery" ];
            middle = [ "media" ];
            right = [ "volume" "bluetooth" "clock" "systray" "notifications" ];
          };
        }
        else throw "[nivem] host = ${host}";
    };

    override = {
      # TODO: This doesn't work yet
      bar.workspaces.showApplicationIconMap.neovide = "";
    };

    # TODO: Ugly
    settings = {
      bar.launcher.autoDetectIcon = true;
      bar.workspaces.show_icons = true;
      menus.clock.time.hideSeconds = true;
      menus.clock.time.military = true;
      menus.clock.weather.key = "c6014dc2059a42f9ab5212404242911";
      menus.clock.weather.location = "Brisbane";
      menus.clock.weather.unit = "metric";
      menus.dashboard.directories.enabled = false;
      menus.dashboard.powermenu.avatar.image = "${./assets/rezero.png}";
      menus.dashboard.powermenu.avatar.name = "nivem";
      menus.dashboard.stats.enable_gpu = true;
      menus.media.displayTime = true;
      menus.media.displayTimeTooltip = true;
      # theme.bar.transparent = true;
      theme.bar.floating = true;
      theme.font.name = "CaskaydiaCove NF";
      theme.font.size = "14px";
      theme.bar.location = "top";
      menus.dashboard.powermenu.logout = "uwsm stop";

      bar.workspaces = {
        numbered_active_indicator = "underline";
        showApplicationIcons = true;
        showWsIcons = true;
      };
    };
  };

  ##############################################
  #                 COMPOSITOR                 #
  ##############################################
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = let
        displayForHost = {
          zephyrus = "eDP-2";
          fractal = "DP-2";
        };
        display =
          if displayForHost ? ${host} then
            displayForHost.${host}
          else
            throw "[nivem] host = ${host}";
      in [
        # display, resolution, position, scale
        "${display}, highrr, auto, 1"
        ", preferred, auto, 1"
      ];

      layerrule = [
        "blur, rofi"
        "blur, logout_dialog"
      ];

      env = [
        "TERM, kitty"
        "EDITOR, nvim"
        "GTK_THEME, ${config.gtk.theme.name}"
        "XCURSOR_THEME, ${config.gtk.cursorTheme.name}"
        "XCURSOR_SIZE, ${toString config.gtk.cursorTheme.size}"
        "HYPRCURSOR_THEME, ${config.gtk.cursorTheme.name}"
        "HYPRCURSOR_SIZE, ${toString config.gtk.cursorTheme.size}"
      ];

      exec-once = [
        "ulauncher"
        "hypridle"
        "hyprctl setcursor ${config.gtk.cursorTheme.name} ${toString config.gtk.cursorTheme.size}"
      ];

      general = {
        layout = "master";
        gaps_in = 10;
        gaps_out = 20;
        border_size = 0;
        resize_on_border = true;
      };

      decoration = {
        rounding = 0;
        blur = {
          size = 9;
          noise = 0;
          passes = 2;
          vibrancy = 1;
          contrast = 1;
          brightness = 1;
        };
        shadow = {
          range = 20;
          render_power = 1;
          color = "rgba(0,0,0, 0.9)";
          color_inactive = "rgba(0,0,0, 0.7)";
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
      
      master.mfact = 0.5;

      windowrulev2 = [ "opacity 0.9 override 0.9 override 0.9, class:kitty" ];

      "$ENTER" = 36;
      "$SPACE" = 65;

      bind = let
        bctl = "${pkgs.brightnessctl}/bin/brightnessctl";
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        wallpaper = pkgs.writeShellApplication {
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
              ${notify "Got exit code $code from 'swww' while changing wallpaper"}
              exit 1
            fi
          '';
        };
      in [
        "     ,    F10, togglefloating,"
        "     ,    F11, fullscreen,"
        "  ALT,     F4, killactive,"
        "SUPER,  SPACE, exec, kitty"
        "SUPER,      B, exec, brave"
        "SUPER,      N, exec, nautilus"
        "SUPER,      L, exec, pidof wlogout || wlogout -b 3"
        "SUPER, ENTER, exec, ulauncher-toggle"

        "SUPER,      A, exec, ${wallpaper}/bin/wallpaper ${../../wallpapers/anime}"
        "SUPER,      H, exec, ${wallpaper}/bin/wallpaper ${../../wallpapers/mountain}"

        # master layout key binding
        "SUPER      ,      J, layoutmsg, cyclenext"
        "SUPER      ,      K, layoutmsg, cycleprev"
        "SUPER      ,      I, layoutmsg, addmaster"
        "SUPER      ,      D, layoutmsg, removemaster"
        "SUPER SHIFT,      J, layoutmsg, swapnext"
        "SUPER SHIFT,      K, layoutmsg, swapprev"
        "SUPER SHIFT,      I, layoutmsg, orientationnext"
        "SUPER SHIFT,      D, layoutmsg, orientationprev"
        "SUPER SHIFT,      L, layoutmsg, mfact +0.1"
        "SUPER SHIFT,      H, layoutmsg, mfact -0.1"
        "SUPER SHIFT, $ENTER, layoutmsg, swapwithmaster"

        "SUPER      ,   S, togglespecialworkspace,"
        "SUPER SHIFT,   S, movetoworkspace, special"

        "ALT        , TAB,       workspace      , e+1"
        "SUPER      ,   1,       workspace      , 1"
        "SUPER      ,   2,       workspace      , 2"
        "SUPER      ,   3,       workspace      , 3"
        "SUPER      ,   4,       workspace      , 4"
        "SUPER      ,   5,       workspace      , 5"
        "SUPER SHIFT,   1, movetoworkspacesilent, 1"
        "SUPER SHIFT,   2, movetoworkspacesilent, 2"
        "SUPER SHIFT,   3, movetoworkspacesilent, 3"
        "SUPER SHIFT,   4, movetoworkspacesilent, 4"
        "SUPER SHIFT,   5, movetoworkspacesilent, 5"

        ", XF86AudioRaiseVolume , exec, ${pamixer} -i 10"
        ", XF86AudioLowerVolume , exec, ${pamixer} -d 10"
        ", XF86AudioMute        , exec, ${pamixer} -t"
        ", XF86AudioMicMute     , exec, ${pamixer} --default-source -t"
        ", XF86MonBrightnessUp  , exec, ${bctl} set +10%"
        ", XF86MonBrightnessDown, exec, ${bctl} set 10%-"
        ", XF86KbdBrightnessUp  , exec, ${bctl} -d asus::kbd_backlight set +1"
        ", XF86KbdBrightnessDown, exec, ${bctl} -d asus::kbd_backlight set 1-"
      ];

      bindm = [
        "ALT, mouse:272, movewindow"
        "ALT, mouse:273, resizewindow"
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };

    systemd.enable = false;
  };
}
