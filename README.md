<!-- README.md is generated from README.Rmd. Please edit that file -->

# pkgmaker <img src="icon/hexlogo.png" align="right" height="138" alt="pkgmaker logo" />

<!-- badges: start -->

![status](https://img.shields.io/badge/status-experimental-orange)
![platform](https://img.shields.io/badge/platform-linux--only-lightgrey)
![language](https://img.shields.io/badge/language-R%20%2B%20fish-blue)

<!-- badges: end -->

## Overview

pkgmaker is a minimal CLI tool to convert a directory of R scripts into a
ready-to-build R package.

It is designed for fast prototyping: you write scripts, run a command,
and get a valid R package with dependencies, documentation, and install
support.


## Installation

``` bash
git clone https://github.com/jcarocont/pkgname.git
cd pkgname
./configscript.sh
```
Ensure `~/.local/bin` is in your PATH.

## Usage

### Assemble package (move scripts and structure folderss)

``` bash
pkgmaker nsmbl
```

Ignore files:

``` bash
pkgmaker nsmbl --ignore file1 file2
```

### Build package

``` bash
pkgmaker build
```

### Install package

``` bash
pkgmaker install
```

## deps.toml (optional)

``` toml
[imports]
dplyr >=1.1.0
ggplot2 >=3.4.0
data.table
```

If not present, dependencies are inferred from `library()` / `require()`
calls.

## Structure

After `nsmbl`:

    .
    ├── R/
    ├── DESCRIPTION
    ├── NAMESPACE
    ├── man/
    └── data/

## Notes

-   Designed for quick package development
-   Little system dependencies beyond R, self config
-   Works well in Unix-like environments


