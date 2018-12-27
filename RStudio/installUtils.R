warnings <- list()
report <- function(messages) {
  msg <- paste0(messages)
  message(msg)
  warnings <<- list(warnings, list(msg))
}

createReport <- function() {
  failedInstallations <- unlist(warnings)
  if (length(failedInstallations) == 0) {
    print("All installations passed")
    write("All installations passed", file = "installationpassed")
  } else {
    print(paste0(length(failedInstallations), " Error(-s):"))
    print(failedInstallations)
  }
}

doInstall <- function(name, version) {
  print(paste("Installing: ", name, "=", version))
  devtools::install_version(name, version = version, repos = "http://cran.rstudio.com/")
  if (length(which(installed.packages() == name)) == 0 || installed.packages()[name, 3] != version) {
    report(paste0("Failed to install Package ", name, "=", version))
  }
}

checkInstalled <- function(packages){
  for (name in names(packages)) {
    version = packages[name]
    ip <- installed.packages()
    found <- which(ip == name)
    if (length(found) == 0 || length(which(version == ip[found, 3])) == 0) {
      report(paste0("Package ", name, "=", version, " is not installed."))
    }
  }
}

installAll <- function(packages) {
  for (name in names(packages)) {
    version = packages[name]
    ip <- installed.packages()
    found <- which(ip == name)
    if (length(found) > 0) {
      installedVersion <- ip[found[1], 3]
      if (length(which(version == installedVersion)) > 0) {
        report(paste0(length(which(version == installedVersion)), " Package ", name, "=", version, " already installed"))
      } else {
        warning(paste0(length(found), " Package ", name, "=", installedVersion, " already installed. Installing ",version))
        doInstall(name, version)
      }
    } else {
      doInstall(name, version)
    }
  }
}
