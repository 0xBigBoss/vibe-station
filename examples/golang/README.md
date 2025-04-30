# Golang Example for Vibe Station

This is a simple Golang example project that demonstrates how to use the Vibe Station code-server workspace with a Go project.

## Project Structure

- `main.go` - A simple HTTP server that responds with "Hello from Vibe Station Golang Example!"
- `go.mod` - Go module definition
- `flake.nix` - Optional Nix flake for project-specific development environment (can be used with direnv)

## Using with Vibe Station

1. Start your Vibe Station code-server workspace following the instructions in the main project README.md
2. Open this example directly in code-server by using the folder query parameter:
   ```
   http://localhost:7080/?folder=/app/examples/golang
   ```
3. The workspace will automatically have all the necessary Go tools installed via Home Manager
4. Run the server with `go run main.go`
5. Access the server at http://localhost:8080

## Testing the Example

To test this example:

```bash
# Run the server
go run main.go
```

Then open a browser and navigate to http://localhost:8080. You should see "Hello from Vibe Station Golang Example!".
