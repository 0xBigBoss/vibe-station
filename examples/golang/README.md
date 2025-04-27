# Golang Example for Vibe Station

This is a simple Golang example project that demonstrates how to use the Vibe Station code-server workspace with a Go project.

## Project Structure

- `main.go` - A simple HTTP server that responds with "Hello from Vibe Station Golang Example!"
- `go.mod` - Go module definition
- `flake.nix` - Nix flake for the Go development environment

## Using with Vibe Station

1. Start your Vibe Station code-server workspace following the instructions in the main project README.md
2. Create a new workspace in code-server using this example
3. Open the workspace in VS Code
4. The workspace will automatically have all the necessary Go tools installed
5. Run the server with `go run main.go`
6. Access the server at http://localhost:8080

## Development Environment

The `flake.nix` file defines a development environment with:

- Go compiler and standard library
- gopls (Go language server)
- Various Go development tools (outline, code, pkgs, def, lint)

When you enter the development shell (which happens automatically in the code-server workspace), you'll have access to all these tools.

## Testing the Example

To test this example:

```bash
# Enter the development shell
nix develop

# Run the server
go run main.go
```

Then open a browser and navigate to http://localhost:8080. You should see "Hello from Vibe Station Golang Example!".
