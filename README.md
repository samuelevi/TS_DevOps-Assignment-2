# Assignment 2 - Dockerized Diagnostic CLI

The same kind of diagnostic tool from Assignment 1, but packaged in a Docker container. Runs system checks, network diagnostics, and disk reporting through a single entrypoint script.

## Setup

You need Docker installed and running.

Build the image:

```bash
docker build -t diagnostic-tool .
```

Or with Compose:

```bash
docker compose build
```

To run the test scripts locally, make them executable first:

```bash
chmod +x app/*.sh test.sh grade.sh
```

## Usage

Everything runs through Docker. The container's entrypoint is `diagnostic.sh`, and you pass a command as the argument.

```bash
docker run --rm diagnostic-tool help
docker run --rm diagnostic-tool system
docker run --rm diagnostic-tool disk
docker run --rm diagnostic-tool network google.com
```

With Compose:

```bash
docker compose run --rm diagnostic system
docker compose run --rm diagnostic network google.com
```

**Commands:**
- `system` -- shows hostname, user, OS, kernel, uptime, CPU, and memory info
- `network <host>` -- resolves the host, pings it, and shows network interfaces
- `disk` -- shows disk usage via `df -h`
- `help` -- prints available commands

**Exit codes:** `0` for success, `1` for runtime failures, `2` for bad input or unknown commands.

## Testing

Run the student tests (builds the image and validates each command):

```bash
./test.sh
```

Run the full grader:

```bash
./grade.sh
```

The grader checks file structure, Dockerfile contents, that the image builds, all commands work correctly inside the container, invalid commands fail properly, Compose config is valid, and the student tests pass.

## Project Structure

```
assignment-2/
├── app/
│   ├── diagnostic.sh    # main CLI script
│   └── health-check.sh  # simple health check
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── test.sh
├── grade.sh
└── README.md
```

## Assumptions

- Docker is installed and the daemon is running
- The container is Alpine Linux 3.19 based -- all diagnostics run inside the container, not on the host
- Network checks inside the container use Docker's network namespace, so results might differ from running on the host directly
- No hardcoded machine-specific values
