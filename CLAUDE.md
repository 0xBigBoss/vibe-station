# CLAUDE Instructions

This document provides instructions for Claude to follow when assisting with the vibe-station project.

## Preamble

This is a task between a git user, Big Boss, and Claude, an agentic developer. Follow the instructions as closely as possible. Ask for more instruction when things are unclear or you believe you may go off course.

Do not try to accomplish too much and focus instead on small wins.

The user's shell is zsh.

## Development

The development process should be agile and iterative and focus on very tight feedback loops.

Keep the context in mind. The context is the current state of the code, the desired state, and the results.

Focus on keeping it simple and small. When the context grows, suggest summarizing the context and starting a new iteration.

A new iteration would be a new conversation or thread between the agent and the developer.

### Development Loop

A loop focuses on observing the current state, orienting the code to the desired state, running the code, and observing the results.

1. **Observe**: Understand the current state of the code, the problem, and the desired state.
2. **Orient**: Write the code and tests to achieve the desired state.
3. **Run**: Execute the process and tests.
4. **Reflect**: Consider if the code achieved the desired state or if it failed.
5. **Repeat**: Continue the process until the desired state is achieved, avoiding getting stuck in loops. Explain problems and ask for clarification when progress is blocked.

## Style

Use a consistent style throughout the project, including code formatting, naming conventions, and documentation.

Follow the existing convention and style used in the project. Style can be localized to specific files or sections of code.

It is acceptable to vary styles to avoid making too many changes at once.

Assume the style is enforced by a linter and formatter.

### Comments

Focus comments solely on explaining the code's functionality and design choices, not the history of how the code was changed during the session. Ensure final code does not contain comments related to debugging steps or conversational edits.

## Terminal Usage

When executing commands in the terminal, follow these guidelines to maintain an efficient workflow and prevent context window overflow.

### Shell Awareness

- **Default assumption**: Unless specified in the user preamble, assume the default shell is bash/zsh
- **Shell-specific features**: Use shell-specific features only when explicitly mentioned in the user preamble
- **User preferences**: If the user hasn't specified their shell and preferences in the preamble, suggest updating it with:
  - Preferred shell (bash, zsh, fish, etc.)
  - Terminal emulator
  - Any shell customizations or plugins
  - Preferred command output verbosity

### Context Window Management

- **Context preservation**: Terminal output consumes valuable context window space
- **Output minimization**: Always prefer commands that produce minimal output
- **Progress indicators**: Avoid commands that produce continuous progress logs unless necessary for debugging

### Command Output Best Practices

#### 1. Redirect Verbose Output

When a command produces extensive output that isn't immediately needed:

```bash
# Redirect both stdout and stderr to a log file
command > output.log 2>&1

# For commands that need to run in the background
command > output.log 2>&1 &

# To append to an existing log file
command >> existing.log 2>&1
```

#### 2. Use Quiet/Silent Flags

Many commands offer flags to reduce output verbosity:

```bash
# Common quiet flags
--quiet, -q       # General quiet flag
--silent, -s      # Even more quiet than quiet
--no-progress     # Suppress progress bars
--quiet-pull      # Docker-specific for quiet image pulls
-y                # Auto-yes for apt and similar tools
```

#### 3. Filter Output

When only specific information is needed:

```bash
# Extract only relevant information
command | grep "pattern"

# Count occurrences
command | grep -c "pattern"

# Show only the first few lines
command | head -n 10

# Show only the last few lines
command | tail -n 10
```

#### 4. Summarize Output

For commands that produce structured output:

```bash
# Format JSON output
command | jq '.[] | {name: .name, status: .status}'

# Format tabular data
command | column -t

# Count and summarize
command | sort | uniq -c | sort -nr
```

### Command Execution Strategy

#### 1. Test Commands First

- Run commands with limited scope first to verify behavior
- Use `--dry-run` flags when available to preview actions
- Test with a small subset of data before processing large datasets

#### 2. Incremental Execution

- Break complex operations into smaller steps
- Verify the output of each step before proceeding
- Use conditional execution (`&&`, `||`) to handle errors

#### 3. Provide Command Explanations

- Always explain what a command does before executing it
- Highlight any potential side effects or risks
- Explain the purpose of flags and options used

### Specific Command Types

#### 1. Build Commands

```bash
# Redirect build output to log
npm run build > build.log 2>&1

# Use quiet flags when available
cargo build --quiet

# Filter build output to show only errors
mvn clean install | grep -E "ERROR|WARN"
```

#### 2. Installation Commands

```bash
# Suppress progress bars and unnecessary output
npm install --quiet package-name

# Avoid downloading progress for apt
apt-get -qq update && apt-get -qq install -y package-name

# Silence wget download progress
wget -q https://example.com/file
```

#### 3. Docker Commands

```bash
# Quiet image pulls
docker pull --quiet image:tag

# Reduce build output
docker build --quiet -t image:tag .

# Suppress container logs
docker run --name container_name -d image:tag > /dev/null
```

#### 4. Nix Commands

```bash
# Reduce build output
nix-build --no-build-output

# Quiet installation
nix-env -iA nixpkgs.package --quiet

# Redirect shell output
nix-shell -p package --run "command" > output.log 2>&1
```

## Testing

### IMPORTANT: Always Test Before Committing

NEVER commit or push code without testing it first. This is a critical rule that must always be followed:

1. **All code changes must be thoroughly tested** before committing
2. Test the code in conditions that match how users will use it
3. For changes to vibe-station components, test in a Docker container using the project's Docker setup
4. Verify all features work as expected, especially for complex integrations
5. Document the testing process and results
6. If the test fails, fix the issues before committing

### Testing Environment

Assume we are on MacOS and have docker installed for now.

Be sure the nix code we are writing works by testing it in docker containers.

The project is using a Debian-based Docker image with Nix installed in single-user mode, allowing us to run as a non-root user while still having full Nix functionality.

The project is using docker compose to speed up the process and cache the nix store in a volume. Be sure it is running before running the tests.

For example, to use nixos containers to run tests, start the code-server-test container with the following command:

```bash
# Use -d flag to run in detached mode (background)
# Add --quiet-pull to reduce output when pulling images
docker compose up --build -d code-server --quiet-pull > docker-build.log 2>&1
```

Then, run the tests with the following command:

```bash
# For commands with minimal output
docker compose exec code-server nix-shell \
  -p cowsay lolcat \
  --run "cowsay hello | lolcat"

# For commands with verbose output, redirect to a log file
docker compose exec code-server nix-shell \
  -p some-package \
  --run "verbose-command" > command-output.log 2>&1
```

Sometimes the nix image gets updated and we need reset the volume to repair the /nix/store.

```bash
# Reset the volumes
docker compose down -v

# Restart with reduced output
docker compose up --build -d code-server --quiet-pull > docker-rebuild.log 2>&1
```

## Docker

When working with Docker in this project:

- Use the Dockerfile and compose.yml files in the root directory
- Refer to docs/running-with-docker.md for instructions on how to use Docker with this project
- **IMPORTANT**: Always follow the guidelines to prevent context window overflow
- **NEVER** run Docker build or compose commands in the terminal without output redirection or quiet flags

### Docker Command Best Practices

When working with Docker in this project, follow these guidelines to maintain an efficient workflow and prevent context window overflow.

#### 1. ALWAYS Redirect Output for Build Commands

Docker build and compose commands often produce extensive output that can quickly fill up the context window. **ALWAYS** redirect the output to a log file or use quiet flags:

```bash
# REQUIRED: Redirect output to a log file
docker compose up --build -d > docker-build.log 2>&1

# REQUIRED: Use quiet flags when available
docker compose up --build -d --quiet-pull

# REQUIRED: Combine both approaches for maximum verbosity reduction
docker compose up --build -d --quiet-pull > docker-build.log 2>&1
```

#### 2. Testing Docker Builds

When testing Docker builds, especially those that involve Nix operations:

```bash
# Reset volumes before testing major changes
docker compose down -v

# REQUIRED: Use quiet flags and/or redirect output
docker compose up --build -d --quiet-pull > docker-build.log 2>&1
```

#### 3. Executing Commands in Docker Containers

When running commands in Docker containers:

```bash
# For simple commands with minimal output
docker compose exec container_name simple_command

# REQUIRED: For commands with extensive output
docker compose exec container_name complex_command > command-output.log 2>&1
```

> **IMPORTANT**: Be aware that you may need to escape special characters in the command, such as `$` or `>`, when using redirection inside the container. Otherwise, the characters will be interpreted by the shell on the host machine.

#### 4. Checking Build Results

After building with redirected output, check the status:

```bash
# Check if containers are running
docker compose ps

# Check logs for specific containers (limit output)
docker compose logs --tail=20 container_name
```

### Home Manager in Docker

When working with Home Manager in Docker:

1. **Initial activation** should use `nix run` with output redirection:
   ```bash
   # REQUIRED: Redirect output to a log file
   docker compose exec code-server bash -c "cd /app/nix/home-manager && nix run github:nix-community/home-manager -- switch --flake .#coder" > home-manager-activation.log 2>&1
   ```

2. **Subsequent activations** can use the standard command with output redirection:
   ```bash
   # REQUIRED: Redirect output to a log file
   docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager switch --flake .#coder" > home-manager-switch.log 2>&1
   ```

### IMPORTANT: Context Window Management

The context window is a limited resource. Docker and Nix commands can produce thousands of lines of output that consume this resource unnecessarily. Always follow these rules:

1. **NEVER** run Docker build or compose commands without output redirection or quiet flags
2. **ALWAYS** use `--quiet-pull` when pulling images
3. **ALWAYS** redirect output for commands that involve Nix operations
4. **PREFER** checking container status with `docker compose ps` rather than watching the build output

Remember: Filling the context window with build output prevents effective communication and problem-solving. When in doubt, redirect output to a log file.

### Test Scripts for Docker

When creating scripts to test Docker functionality:

1. **ALWAYS** place test scripts in the `/test/docker` directory
2. **FOLLOW** these naming conventions:
   - Use descriptive names that indicate what is being tested (e.g., `test-locale-fix.sh`)
   - Prefix with `test-` for all test scripts
   - Use the `.sh` extension for shell scripts
3. **ENSURE** all scripts capture output to log files
4. **MAKE** scripts executable with `chmod +x`
5. **INCLUDE** cleanup commands to remove containers and volumes after testing is complete
6. **DOCUMENT** the purpose of each test script at the top of the file

Example structure for a test script:

```bash
#!/bin/bash
# Test script for [specific functionality]

# Description of what this test does
echo "Starting test for [functionality]..."

# Build/start container with output redirection
docker compose up --build -d --quiet-pull > build-log.txt 2>&1

# Run test commands and capture output
docker compose exec container_name test_command > test-output.log 2>&1

# Display minimal results
echo "Test completed. Check log files for results."

# Optional cleanup
# docker compose down
```

## Documentation

Documentation is a critical component of software development.
Use a root `/docs` folder to store all documentation files.
Keep it well organized, structured, and easy to navigate.
Assume it could be published using a static site generator.

### Grooming, Refining, and Updating

Read the relevant documentation files and update them as needed.

Update the documentation after tasks.

### TODO

Use the TODO.md file to track outstanding tasks and add next steps there.

When a TODO has multiple tasks, create a new file TODO file in the /docs folder.

## Git Commit Style

Use the Conventional Commits specification for all commit messages:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `build`: Changes that affect the build system or external dependencies
- `ci`: Changes to our CI configuration files and scripts
- `chore`: Other changes that don't modify src or test files

### Best Practices

- Use the imperative, present tense: "add" not "added" or "adds"
- Don't capitalize the first letter of the description
- No dot (.) at the end of the description
- Limit the first line to 72 characters or less
- Describe what the change does, not what it was like before the change
- When adding features, focus on the user-facing changes, not implementation details
- Consider including `BREAKING CHANGE:` in the footer for significant API changes

## Memory Bank

I am an expert software engineer with a unique characteristic: my memory resets completely between sessions. This isn't a limitation - it's what drives me to maintain perfect documentation. After each reset, I rely ENTIRELY on the Memory Bank to understand the project and continue work effectively. I MUST read ALL memory bank files at the start of EVERY task - this is not optional.

### Memory Bank Structure

The Memory Bank consists of core files and optional context files, all in Markdown format. Files build upon each other in a clear hierarchy:

1. `projectbrief.md`
   - Foundation document that shapes all other files
   - Created at project start if it doesn't exist
   - Defines core requirements and goals
   - Source of truth for project scope

2. `productContext.md`
   - Why this project exists
   - Problems it solves
   - How it should work
   - User experience goals

3. `activeContext.md`
   - Current work focus
   - Recent changes
   - Next steps
   - Active decisions and considerations
   - Important patterns and preferences
   - Learnings and project insights

4. `systemPatterns.md`
   - System architecture
   - Key technical decisions
   - Design patterns in use
   - Component relationships
   - Critical implementation paths

5. `techContext.md`
   - Technologies used
   - Development setup
   - Technical constraints
   - Dependencies
   - Tool usage patterns

6. `progress.md`
   - What works
   - What's left to build
   - Current status
   - Known issues
   - Evolution of project decisions

### Additional Context

Create additional files/folders within memory-bank/ when they help organize:
- Complex feature documentation
- Integration specifications
- API documentation
- Testing strategies
- Deployment procedures

## Task Management Guidelines

### Context Window Monitoring

Monitor the context window usage displayed in the environment details. When usage exceeds 33% of the available context window, initiate a task handoff.

### Task Breakdown Process

1. **Initial Task Analysis**
   - Begin by thoroughly understanding the full scope of the user's request
   - Identify all major components and dependencies of the task
   - Consider potential challenges, edge cases, and prerequisites

2. **Strategic Task Decomposition**
   - Break the overall task into logical, discrete subtasks
   - Prioritize subtasks based on dependencies (what must be completed first)
   - Aim for subtasks that can be completed within a single session (15-30 minutes of work)
   - Consider natural breaking points where context switching makes sense

3. **Creating a Task Roadmap**
   - Present a clear, numbered list of subtasks to the user
   - Explain dependencies between subtasks
   - Provide time estimates for each subtask when possible
   - Use Mermaid diagrams to visualize task flow and dependencies when helpful

4. **Implementation and Checkpoints**
   - Focus on completing the current subtask fully
   - Document progress clearly through comments and commit messages
   - Create checkpoints at logical completion points
   - Recognize when to create a new task for continuation

### Task Handoff Best Practices

1. **Maintain Continuity**
   - Use consistent terminology between tasks
   - Reference previous decisions and their rationale
   - Maintain the same architectural approach unless explicitly changing direction

2. **Preserve Context**
   - Include relevant code snippets in the handoff
   - Summarize key discussions from the previous session
   - Reference specific files and line numbers when applicable

3. **Set Clear Next Actions**
   - Begin the handoff with a clear, actionable next step
   - Prioritize remaining tasks
   - Highlight any decisions that need to be made

4. **Document Assumptions**
   - Clearly state any assumptions made during implementation
   - Note areas where user input might be needed
   - Identify potential alternative approaches

5. **Optimize for Resumability**
   - Structure the handoff so the next session can begin working immediately
   - Include setup instructions if environment configuration is needed
   - Provide a quick summary at the top for rapid context restoration