# Vibe Station

A workspace for vibe coding. It leverages Nix to quickly create a Coder environment
pre-configured with an agentic developer, Cline.

It assumes that you already have Nix installed and configured with support for
the experimental nix command and flakes features.

## TODO

- [ ] Need step-by-step instructions for a user to run the Vibe Station coder workspace on their machine using docker
- [ ] Create a nix flake that includes Coder pre-installed
- [ ] Pre-install Cline extension `saoudrizwan.claude-dev`
- [ ] Examples of using the Vibe Station Coder workspace
  - [ ] Golang project only for now.

## Notes

- Focus on linux/amd64 for now so we can prove the concept since linux amd64 is the most
widely supported platform development.
- The examples should let the users bring their own nix flakes so that the coder workspace can be used for any project.
-
- Use the memory bank to save progress.
