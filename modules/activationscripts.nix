{ pkgs, ... }:

{
    # Custom activation script for UI sounds
    system.activationScripts.ui-sounds = ''
        if [ ! -d /usr/share/sounds/modern-minimal-ui-sounds ]; then
            mkdir -p /usr/share/sounds/modern-minimal-ui-sounds
            cd /tmp
            ${pkgs.git}/bin/git clone https://github.com/cadecomposer/modern-minimal-ui-sounds.git
            cp -r modern-minimal-ui-sounds/* /usr/share/sounds/modern-minimal-ui-sounds/
            rm -rf modern-minimal-ui-sounds
            chmod -R 644 /usr/share/sounds/modern-minimal-ui-sounds/
            find /usr/share/sounds/modern-minimal-ui-sounds/ -type d -exec chmod 755 {} \;
        fi
    '';
}