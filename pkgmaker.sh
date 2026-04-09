#!/usr/bin/env sh
cmd="$1"
shift

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
R_SCRIPTS="$SCRIPT_DIR/R"

pkgmaker_nsmbl() {
    # parsear --ignore
    ignore_list="deps.toml"
    skip_next=0

    for arg in "$@"; do
        if [ "$arg" = "--ignore" ]; then
            skip_next=1
            continue
        fi
        if [ "$skip_next" = "1" ]; then
            ignore_list="$ignore_list $arg"
        fi
    done

    # crear estructura
    Rscript -e "source('$R_SCRIPTS/pkgmaker_core.r'); pkgmaker_create(basename(getwd()), '.')"
    mkdir -p R

    for file in $(find . -maxdepth 1 \( -iname "*.r" -o -iname "*.txt" \)); do
        fname=$(basename "$file")
        base=$(echo "$fname" | sed 's/\.\(txt\|r\|R\)$//')

        # ignorar si está en la lista
        for ign in $ignore_list; do
            if [ "$base" = "$ign" ]; then
                continue 2
            fi
        done

        # evitar R/
        case "$file" in
            ./R/*) continue ;;
        esac

        mv "$file" "R/$base.R"
    done
}

pkgmaker_build() {
    Rscript "$R_SCRIPTS/update_desc.R"
    Rscript -e "roxygen2::roxygenise()" --no-save
}

pkgmaker_install() {
    Rscript -e "devtools::install()" --no-save
}

case "$cmd" in
    nsmbl)
        pkgmaker_nsmbl "$@"
        ;;
    build)
        pkgmaker_build
        ;;
    install)
        pkgmaker_install
        ;;
    *)
        echo "Uso:"
        echo "  pkgmaker nsmbl [--ignore name1 name2]"
        echo "  pkgmaker build"
        echo "  pkgmaker install"
        ;;
esac
