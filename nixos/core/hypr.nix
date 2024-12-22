# NOTE: Hyprland config can be found in home.nix
{ inputs, pkgs, host, ... }:
{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];
  # home.packages = [ inputs.hyprpanel.packages.${pkgs.system}.default ];

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
      ] ++ (let bctl = "${pkgs.brightnessctl}/bin/brightnessctl"; in
      if host == "zephyrus" then
      [
        { # Dim laptop screen after 5 minutes
          timeout = 300;
          on-timeout = "${bctl} -s set 10";
          on-resume = "${bctl} -r";
        }
        { # Turn off keyboard backlight after 5 minutes
          timeout = 300;
          on-timeout = "${bctl} -sd asus::kbd_backlight set 0";
          on-resume = "${bctl} -rd asus::kbd_backlight";
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

  programs.hyprpanel = {
    enable = true;
    theme = "gruvbox";
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
      theme.bar.transparent = true;
      theme.font.name = "CaskaydiaCove NF";
      theme.font.size = "16px";
    };
  };
}
