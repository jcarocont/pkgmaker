pkg <- basename(getwd())



d <- desc::description$new()

# -------- deps --------
if (file.exists("deps.toml")) {
  raw <- readLines("deps.toml")

  start <- grep("^\\[imports\\]", raw)
  if (length(start) > 0) raw <- raw[(start+1):length(raw)]

  raw <- trimws(raw)
  raw <- raw[raw != ""]
  raw <- raw[!grepl("^\\[", raw)]

  parse_dep <- function(x) {
    m <- regmatches(x, regexec("^([a-zA-Z0-9.]+)\\s*(>=|==)?\\s*([0-9.]*)$", x))[[1]]
    pkg <- m[2]
    op  <- m[3]
    ver <- m[4]

    if (is.na(op) || op == "" || ver == "") {
      list(pkg = pkg, ver = NULL)
    } else {
      list(pkg = pkg, ver = paste0(op, " ", ver))
    }
  }

  deps <- lapply(raw, parse_dep)

} else {
  files <- list.files("R", pattern="\\.R$", full.names=TRUE)
  code <- paste(unlist(lapply(files, readLines)), collapse="\n")

  pkgs <- unique(regmatches(
    code,
    gregexpr("(?<=library\\(|require\\()[a-zA-Z0-9.]+", code, perl=TRUE)
  ))

  deps <- lapply(pkgs, function(p) list(pkg = p, ver = NULL))
}

# limpiar
base_pkgs <- c("base","utils","stats","methods","grDevices","graphics","tools")
deps <- Filter(function(x) x$pkg != "" && !(x$pkg %in% base_pkgs), deps)

# -------- DESCRIPTION --------
d$set("Package", pkg)
d$set("Version", "0.0.0.9000")
d$set("Title", paste("Package", pkg))
d$set("Description", paste("Tools for", pkg, "analysis."))
d$set("License", "MIT")
d$set("Encoding", "UTF-8")
d$set("LazyData", "true")

# IMPORTS correcto
for (dep in deps) {
  if (is.null(dep$ver)) {
    d$set_dep("Imports", dep$pkg)
  } else {
    d$set_dep("Imports", dep$pkg, dep$ver)
  }
}

d$write(file = "DESCRIPTION")

writeLines("", "NAMESPACE")

message("✓ DESCRIPTION generado (correcto)")
