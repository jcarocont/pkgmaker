# R/update_desc.R

# -------- utils --------
`%||%` <- function(a, b) if (!is.null(a) && a != "") a else b

# -------- section normalizer --------
normalize_section <- function(s) {
  map <- c(
    "imports"   = "Imports",
    "depends"   = "Depends",
    "suggests"  = "Suggests",
    "enhances"  = "Enhances",
    "linkingto" = "LinkingTo",
    "package"   = "Package",
    "authors"   = "Authors"
  )
  m <- map[[tolower(s)]]
  if (!is.null(m)) m else tools::toTitleCase(s)
}

# -------- toml parser --------
parse_toml <- function(path) {
  raw <- readLines(path, warn = FALSE)
  raw <- trimws(raw)
  raw <- raw[!grepl("^#", raw)]

  result       <- list()
  current_section <- NULL
  person_list  <- list()
  current_person  <- NULL

  flush_person <- function() {
    if (!is.null(current_person) && length(current_person) > 0) {
      person_list[[length(person_list) + 1]] <<- current_person
      current_person <<- NULL
    }
  }

  for (line in raw) {
    if (line == "") next

    # [[nested]] — new person entry
    if (grepl("^\\[\\[.*\\]\\]$", line)) {
      flush_person()
      current_person <- list()
      next
    }

    # [section]
    if (grepl("^\\[.*\\]$", line)) {
      flush_person()
      current_section <- normalize_section(gsub("\\[|\\]", "", line))
      next
    }

    # Imports lines — handle BEFORE key=value because >= contains =
    if (!is.null(current_section) && current_section == "Imports") {
      result[["Imports_raw"]] <- c(result[["Imports_raw"]], line)
      next
    }

    # key = value
    if (grepl("=", line)) {
      key   <- tools::toTitleCase(trimws(sub("=.*", "", line)))
      value <- trimws(sub("[^=]+=", "", line))
      value <- gsub('^"|"$', "", value)

      # role = ["aut", "cre"] -> vector
      if (grepl("^\\[", value)) {
        value <- gsub("\\[|\\]", "", value)
        value <- trimws(unlist(strsplit(value, ",")))
        value <- gsub('^"|"$', "", value)
      }

      if (!is.null(current_person)) {
        current_person[[key]] <- value
      } else if (!is.null(current_section)) {
        result[[current_section]][[key]] <- value
      }
    }
  }

  flush_person()
  if (length(person_list) > 0) result[["Authors"]][["persons"]] <- person_list

  result
}

# -------- dep parser --------
parse_dep <- function(x) {
  m <- regmatches(x, regexec("^([a-zA-Z0-9.]+)\\s*(>=|==)?\\s*([0-9.]*)$", x))[[1]]
  pkg <- m[2]; op <- m[3]; ver <- m[4]
  if (is.na(op) || op == "" || ver == "") list(pkg = pkg, ver = NULL)
  else list(pkg = pkg, ver = paste0(op, " ", ver))
}

# -------- main --------
base_pkgs <- c("base","utils","stats","methods","grDevices","graphics","tools")

if (file.exists("deps.toml")) {
  toml <- parse_toml("deps.toml")

  pkg_meta    <- toml[["Package"]]
  pkg_name    <- pkg_meta[["Name"]]        %||% basename(getwd())
  pkg_version <- pkg_meta[["Version"]]     %||% "0.0.0.9000"
  pkg_title   <- pkg_meta[["Title"]]       %||% paste("Package", pkg_name)
  pkg_desc    <- pkg_meta[["Description"]] %||% paste("Tools for", pkg_name, "analysis.")
  pkg_license <- pkg_meta[["License"]]     %||% "MIT"

  persons <- toml[["Authors"]][["persons"]]
  if (!is.null(persons) && length(persons) > 0) {
    author_strings <- lapply(persons, function(p) {
      nm    <- strsplit(trimws(p[["Name"]]), " ")[[1]]
      first <- nm[1]
      last  <- if (length(nm) > 1) paste(nm[-1], collapse = " ") else ""
      email <- if (!is.null(p[["Email"]])) paste0(', email = "', p[["Email"]], '"') else ""
      roles <- if (!is.null(p[["Role"]])) {
        paste0(', role = c(', paste0('"', p[["Role"]], '"', collapse = ", "), ')')
      } else ""
      paste0('person("', first, '", "', last, '"', email, roles, ')')
    })
    authors_field <- paste(author_strings, collapse = ",\n    ")
  } else {
    authors_field <- NULL
  }

  raw_deps <- trimws(toml[["Imports_raw"]])
  raw_deps <- raw_deps[!is.null(raw_deps) & raw_deps != ""]
  deps <- lapply(raw_deps, parse_dep)

} else {
  pkg_name    <- basename(getwd())
  pkg_version <- "0.0.0.9000"
  pkg_title   <- paste("Package", pkg_name)
  pkg_desc    <- paste("Tools for", pkg_name, "analysis.")
  pkg_license <- "MIT"
  authors_field <- NULL

  files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  code  <- paste(unlist(lapply(files, readLines)), collapse = "\n")
  pkgs  <- unique(regmatches(code,
    gregexpr("(?<=library\\(|require\\()[a-zA-Z0-9.]+", code, perl = TRUE))[[1]])
  deps  <- lapply(pkgs, function(p) list(pkg = p, ver = NULL))
}

deps <- Filter(function(x) x$pkg != "" && !(x$pkg %in% base_pkgs), deps)

# -------- write DESCRIPTION --------
d <- desc::description$new("!new")
d$set("Package",     pkg_name)
d$set("Version",     pkg_version)
d$set("Title",       pkg_title)
d$set("Description", pkg_desc)
d$set("License",     pkg_license)
d$set("Encoding",    "UTF-8")
d$set("LazyData",    "true")

if (!is.null(authors_field)) {
  d$set("Authors@R", authors_field)
  d$del("Author")
  d$del("Maintainer")
}

for (dep in deps) {
  if (is.null(dep$ver)) d$set_dep(dep$pkg, "Imports")
  else                  d$set_dep(dep$pkg, "Imports", dep$ver)
}

d$write(file = "DESCRIPTION")
message("✓ DESCRIPTION generado")
