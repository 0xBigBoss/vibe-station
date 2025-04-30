# Terminal Usage

When executing commands in the terminal, follow these guidelines to maintain an efficient workflow and prevent context window overflow.

## Shell Awareness

- **Default assumption**: Unless specified in the user preamble, assume the default shell is bash/zsh
- **Shell-specific features**: Use shell-specific features only when explicitly mentioned in the user preamble
- **User preferences**: If the user hasn't specified their shell and preferences in the preamble, suggest updating it with:
  - Preferred shell (bash, zsh, fish, etc.)
  - Terminal emulator
  - Any shell customizations or plugins
  - Preferred command output verbosity

## Context Window Management

- **Context preservation**: Terminal output consumes valuable context window space
- **Output minimization**: Always prefer commands that produce minimal output
- **Progress indicators**: Avoid commands that produce continuous progress logs unless necessary for debugging

## Command Output Best Practices

### 1. Redirect Verbose Output

When a command produces extensive output that isn't immediately needed:

```bash
# Redirect both stdout and stderr to a log file
command > output.log 2>&1

# For commands that need to run in the background
command > output.log 2>&1 &

# To append to an existing log file
command >> existing.log 2>&1
```

### 2. Use Quiet/Silent Flags

Many commands offer flags to reduce output verbosity:

```bash
# Common quiet flags
--quiet, -q       # General quiet flag
--silent, -s      # Even more quiet than quiet
--no-progress     # Suppress progress bars
--quiet-pull      # Docker-specific for quiet image pulls
-y                # Auto-yes for apt and similar tools
```

### 3. Filter Output

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

### 4. Summarize Output

For commands that produce structured output:

```bash
# Format JSON output
command | jq '.[] | {name: .name, status: .status}'

# Format tabular data
command | column -t

# Count and summarize
command | sort | uniq -c | sort -nr
```

## Command Execution Strategy

### 1. Test Commands First

- Run commands with limited scope first to verify behavior
- Use `--dry-run` flags when available to preview actions
- Test with a small subset of data before processing large datasets

### 2. Incremental Execution

- Break complex operations into smaller steps
- Verify the output of each step before proceeding
- Use conditional execution (`&&`, `||`) to handle errors

### 3. Provide Command Explanations

- Always explain what a command does before executing it
- Highlight any potential side effects or risks
- Explain the purpose of flags and options used

## Specific Command Types

### 1. Build Commands

```bash
# Redirect build output to log
npm run build > build.log 2>&1

# Use quiet flags when available
cargo build --quiet

# Filter build output to show only errors
mvn clean install | grep -E "ERROR|WARN"
```

### 2. Installation Commands

```bash
# Suppress progress bars and unnecessary output
npm install --quiet package-name

# Avoid downloading progress for apt
apt-get -qq update && apt-get -qq install -y package-name

# Silence wget download progress
wget -q https://example.com/file
```

### 3. Docker Commands

```bash
# Quiet image pulls
docker pull --quiet image:tag

# Reduce build output
docker build --quiet -t image:tag .

# Suppress container logs
docker run --name container_name -d image:tag > /dev/null
```

### 4. Nix Commands

```bash
# Reduce build output
nix-build --no-build-output

# Quiet installation
nix-env -iA nixpkgs.package --quiet

# Redirect shell output
nix-shell -p package --run "command" > output.log 2>&1
```

## Terminal Session Management

- **Session persistence**: For long-running commands, consider using tools like `tmux` or `screen`
- **Background processes**: Use `&` and `nohup` for commands that don't need interactive monitoring
- **Job control**: Leverage job control (`jobs`, `fg`, `bg`) to manage multiple processes

## Error Handling

- **Capture errors**: Always redirect stderr when logging output
- **Exit codes**: Check command exit codes to verify success
- **Fallback commands**: Provide alternative commands if primary ones fail

Remember: The goal is to maintain a clean context window while still providing all necessary information for effective development. When in doubt, prefer less output over more, and provide mechanisms to access full logs if needed.
