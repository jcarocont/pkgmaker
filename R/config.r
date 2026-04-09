# R/config.r
# Instalador automático de dependencias para la app

setup_app_dependencies <- function() {
  required_pkgs <- c("roxygen2", "devtools", "rcmdcheck", "usethis","desc")
  
  to_install <- character(0)
  
  for (pkg in required_pkgs) {
    if (!requireNamespace(pkg, quietly = FALSE)) {
      message(sprintf("Falta dependencia: %s. Instalando...", pkg))
      to_install <- c(to_install, pkg)
    }
  }
  
  if (length(to_install) > 0) {
    install.packages(to_install, repos = "https://cloud.r-project.org")
    message("✓ Dependencias instaladas correctamente.")
  } else {
    message("✓ Todas las dependencias están presentes.")
  }
  
  invisible(TRUE)
}
