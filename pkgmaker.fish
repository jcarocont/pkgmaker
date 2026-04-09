#!/usr/bin/env fish

set cmd $argv[1]
set SCRIPT_PATH (realpath (status --current-filename))
set SCRIPT_DIR (dirname $SCRIPT_PATH)
set R_SCRIPTS $SCRIPT_DIR/R
function pkgmaker_nsmbl
    set ignores

    # parse flags
    for arg in $argv
        if test "$arg" = "--ignore"
            continue
        end
        set ignores $ignores $arg
    end
    set ignores deps.toml $ignores
    # crear estructura en .
    Rscript -e "source('$R_SCRIPTS/pkgmaker_core.r'); pkgmaker_create(basename(getwd()), '.')"
    mkdir -p R

    for file in (find . -maxdepth 1 \( -iname "*.r" -o -iname "*.txt" \))
        set fname (basename $file)
        set base (string replace -r '\.(txt|r|R)$' '' $fname)

        # ignorar si match
        if contains $base $ignores
            continue
        end

        # evitar R/
        if string match -q "./R/*" $file
            continue
        end

        set newname "$base.R"
        mv $file R/$newname
    end
end

function pkgmaker_build
    Rscript $R_SCRIPTS/update_desc.R
    Rscript -e "roxygen2::roxygenise()" --no-save
end

function pkgmaker_install
    Rscript -e "devtools::install()" --no-save
end

switch $cmd
    case nsmbl
        pkgmaker_nsmbl $argv[2..-1]

    case build
        pkgmaker_build

    case install
        pkgmaker_install

    case '*'
        echo "Uso:"
        echo "  pkgmaker nsmbl [--ignore name1 name2]"
        echo "  pkgmaker build"
        echo "  pkgmaker install"
end
