# Docker

When working with Docker in this project:

- Use the Dockerfile and docker-compose.yml files in the root directory
- Refer to docs/running-with-docker.md for instructions on how to use Docker with this project
- When testing, use the commands specified in .clinerules/03-testing.md
- **IMPORTANT**: Always follow the guidelines in .clinerules/03-docker-commands.md to prevent context window overflow
- **NEVER** run Docker build or compose commands without output redirection or quiet flags
