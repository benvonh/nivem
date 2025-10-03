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
    file = {
      pfp = {
        source = ../../asset/rezero.png;
        target = ".face";
      };
      wallpaper = {
        source = ../../asset/wallpaper.jpg;
        target = "${config.xdg.userDirs.pictures}/Wallpapers/default.jpg";
      };
    };
  };

  systemd.user.startServices = "sd-switch";
}
