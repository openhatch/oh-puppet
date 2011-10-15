## This seems to be necessary for completely clean VMs
## before any packages will install.
class apt_get_update {
  exec { "apt-get update":
    command => "/usr/bin/apt-get update",
  }

  # Ensure apt-get update has been run before installing any packages
  Exec["apt-get update"] -> Package <| |>
}
