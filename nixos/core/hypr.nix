{ inputs, config, pkgs, osConfig, ... }:
let
  host = osConfig.networking.hostName;
in
{
  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

  programs.caelestia = {
    enable = true;
    cli.enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = let
      theme = {
        name = config.gtk.theme.name;
        cursor = {
          name = config.gtk.cursorTheme.name;
          size = toString config.gtk.cursorTheme.size;
        };
      };
    in
    {
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
      in
      [
        # display, resolution, position, scale
        "${display}, highrr, auto, 1"
        ", highrr, auto, 1"
      ];

      env = [
        "TERM, kitty"
        "EDITOR, nvim"
        "GTK_THEME, ${theme.name}"
        "XCURSOR_THEME, ${theme.cursor.name}"
        "XCURSOR_SIZE, ${theme.cursor.size}"
        "HYPRCURSOR_THEME, ${theme.cursor.name}"
        "HYPRCURSOR_SIZE, ${theme.cursor.size}"
        "QS_ICON_THEME, ${config.gtk.iconTheme.name}"
      ];

      exec-once = [
        "hyprctl setcursor ${theme.cursor.name} ${theme.cursor.size}"
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
          size = 7;
          passes = 2;
        };
        shadow = {
          range = 20;
          render_power = 2;
          color = "rgba(0,0,0, 0.9)";
          color_inactive = "rgba(0,0,0, 0.6)";
        };
      };

      animations = {
        bezier = [
          "jiggle, 0.15, 1.15, 0.50, 1.00"
          "close, 0.00, 0.85, 1.00, 0.85"
        ];
        animation = [
          # name, on/off, speed, curve [,style]
          "fadeOut    , 1, 3,  close"
          # "windowsIn  , 1, 3, jiggle, slide"
          "windowsIn  , 1, 3, jiggle, gnomed"
          # "windowsMove, 1, 3, jiggle, slide"
          "windowsMove, 1, 3, jiggle, gnomed"
          # "windowsOut , 1, 3,  close, slide"
          "windowsOut , 1, 3,  close, gnomed"
          "workspaces , 1, 3, jiggle, slidefade"
        ];
      };

      input = {
        scroll_method = "2fg";
        touchpad.natural_scroll = true;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_min_speed_to_force = 15;
      };

      misc = {
        vrr = 0;
        focus_on_activate = true;
        disable_autoreload = true;
        disable_hyprland_logo = true;
        key_press_enables_dpms = true;
        mouse_move_enables_dpms = true;
        new_window_takes_over_fullscreen = 2;
      };
      
      master.mfact = 0.5;

      windowrulev2 = [ "opacity 0.95 override 0.95 override 0.95, class:kitty" ];

      "$ENTER" = 36;
      "$SPACE" = 65;

      bind = [
        "     ,    F10, togglefloating,"
        "     ,    F11, fullscreen,"
        "  ALT,     F4, killactive,"
        "SUPER,      B, exec, zen"
        "SUPER, $ENTER, exec, kitty"
        "SUPER,      F, exec, nautilus"
        "SUPER,      L, exec, caelestia shell lock lock"
        "SUPER,      M, exec, caelestia shell drawers toggle sidebar"
        "SUPER, $SPACE, exec, caelestia shell drawers toggle launcher"

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
        "SUPER SHIFT,   1, movetoworkspacesilent, 1"
        "SUPER SHIFT,   2, movetoworkspacesilent, 2"
        "SUPER SHIFT,   3, movetoworkspacesilent, 3"

        ", XF86MonBrightnessUp  , exec, caelestia shell brightness set +0.1"
        ", XF86MonBrightnessDown, exec, caelestia shell brightness set 0.1-"
        ", XF86AudioRaiseVolume , exec, ${pkgs.pamixer}/bin/pamixer -i 10"
        ", XF86AudioLowerVolume , exec, ${pkgs.pamixer}/bin/pamixer -d 10"
        ", XF86AudioMute        , exec, ${pkgs.pamixer}/bin/pamixer -t"
        ", XF86AudioMicMute     , exec, ${pkgs.pamixer}/bin/pamixer --default-source -t"
        ", XF86KbdBrightnessUp  , exec, ${pkgs.brightnessctl}/bin/brightnessctl -d asus::kbd_backlight set +1"
        ", XF86KbdBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -d asus::kbd_backlight set 1-"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };

    systemd.enable = false;
  };
}
