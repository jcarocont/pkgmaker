#!/usr/bin/env fish
set SCRIPT_PATH (realpath (status --current-filename))
set SCRIPT_DIR (dirname $SCRIPT_PATH)
set R_SCRIPTS $SCRIPT_DIR/R
Rscript -e "source('$R_SCRIPTS/config.r'); setup_app_dependencies()"
# crear symlink
mkdir -p ~/.local/bin
ln -sf $SCRIPT_DIR/pkgmaker.fish ~/.local/bin/pkgmaker
chmod +x $SCRIPT_DIR/pkgmaker.fish

# asegurar PATH
if not contains ~/.local/bin $fish_user_paths
    set -Ux fish_user_paths ~/.local/bin $fish_user_paths
end

echo "✓ pkgmaker instalado en ~/.local/bin/pkgmaker"
