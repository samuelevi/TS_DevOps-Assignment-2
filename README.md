## Assignment 2 - Dockerized Diagnostic CLI

This is the diagnostic tool from Assignment 1, but now packaged in a Docker container. It can check system info, run network diagnostics, and report disk usage -- all through a single entrypoint script.

## Getting started

Make sure Docker is installed and running, then build the image:

```bash
docker build -t diagnostic-tool .
```

Or use Compose:

```bash
docker compose build
```

If you want to run the scripts locally you'll need to make them executable:

```bash
chmod +x app/*.sh test.sh grade.sh
```

## How to use it

The container's entrypoint is `diagnostic.sh` and you pass a command as the argument:

```bash
docker run --rm diagnostic-tool help
docker run --rm diagnostic-tool system
docker run --rm diagnostic-tool disk
docker run --rm diagnostic-tool network google.com
```

You can also use Compose:

```bash
docker compose run --rm diagnostic system
docker compose run --rm diagnostic network google.com
```

### Available commands

- `system` -- hostname, user, OS, kernel, uptime, CPU and memory info
- `network <host>` -- resolves the host, pings it, lists network interfaces
- `disk` -- disk usage via `df -h`
- `help` -- prints available commands

Exit codes: `0` on success, `1` for runtime errors, `2` for bad input or unknown commands.

## Running the tests

Student tests:

```bash
./test.sh
```

Full grader:

```bash
./grade.sh
```

The grader checks file structure, Dockerfile contents, image build, all commands working in the container, error handling for invalid commands, Compose config, and that the student tests pass.

## Project layout

```
assignment-2/
├── app/
│   ├── diagnostic.sh      # main CLI entrypoint
│   └── health-check.sh    # basic health check
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── test.sh
├── grade.sh
└── README.md
```

## Notes

- Requires Docker to be installed with the daemon running
- Built on Alpine Linux 3.19 -- diagnostics run inside the container, not on the host
- Network checks use Docker's network namespace so results may differ from running directly on the host
- Nothing is hardcoded to any specific machine
