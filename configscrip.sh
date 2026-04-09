#!/usr/bin/env sh
SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
R_SCRIPTS="$SCRIPT_DIR/R"

Rscript -e "source('$R_SCRIPTS/config.r'); setup_app_dependencies()"

# crear symlink
mkdir -p ~/.local/bin
ln -sf "$SCRIPT_DIR/pkgmaker.sh" ~/.local/bin/pkgmaker
chmod +x "$SCRIPT_DIR/pkgmaker.sh"

# asegurar PATH en ~/.bashrc y ~/.profile
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

for rc in "$HOME/.bashrc" "$HOME/.profile"; do
    if [ -f "$rc" ]; then
        if ! grep -qF '.local/bin' "$rc"; then
            echo "$PATH_LINE" >> "$rc"
            echo "✓ PATH agregado a $rc"
        fi
    fi
done

echo "✓ pkgmaker instalado en ~/.local/bin/pkgmaker"
echo "  Recarga tu shell o ejecuta: export PATH=\"\$HOME/.local/bin:\$PATH\""
