terraform {
  cloud {
    organization = "hexlet"

    workspaces {
      name = "ksv2005-app"
    }
  }
}
