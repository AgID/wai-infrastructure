terraform {
  backend "swift" {
    container = "terraform-state"
  }
}
