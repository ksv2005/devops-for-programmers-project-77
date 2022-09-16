terraform {
  cloud {
    organization = "ksv2005"

    workspaces {
      name = "example-workspace"
    }
  }
}
