#!/usr/bin/env bash
set -u

show_help() {
    echo "Usage: diagnostic <command>"
    echo ""
    echo "Commands:"
    echo "  system    Display useful Linux system information"
    echo "  network   Check the supplied host"
    echo "  disk      Display disk information"
    echo "  help      Display this help message"
}

cmd_system() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Current User: $(whoami)"
    echo "Date/Time: $(date)"
    echo "Operating System: $(uname -o 2>/dev/null || uname -s)"
    echo "Kernel Version: $(uname -r)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo ""
    echo "=== CPU Information ==="
    if [ -f /proc/cpuinfo ]; then
        grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //'
        echo "CPU Cores: $(grep -c '^processor' /proc/cpuinfo)"
    fi
    echo ""
    echo "=== Memory Information ==="
    if command -v free >/dev/null 2>&1; then
        free -h
    fi
}

cmd_network() {
    if [ $# -lt 1 ]; then
        echo "Error: Host argument required." >&2
        echo "Usage: diagnostic network <host>" >&2
        exit 2
    fi
    local host="$1"
    echo "=== Network Check: $host ==="
    if command -v getent >/dev/null 2>&1; then
        resolved=$(getent hosts "$host" 2>/dev/null | awk '{print $1}')
        if [ -n "$resolved" ]; then
            echo "Resolved: $resolved"
        else
            echo "Could not resolve: $host"
        fi
    fi
    if command -v ping >/dev/null 2>&1; then
        if ping -c 2 -W 3 "$host" >/dev/null 2>&1; then
            echo "Ping: SUCCESS"
        else
            echo "Ping: FAILED"
        fi
    fi
    if command -v ip >/dev/null 2>&1; then
        echo ""
        echo "=== Network Interfaces ==="
        ip -brief addr show 2>/dev/null
    fi
}

cmd_disk() {
    echo "=== Disk Information ==="
    df -h 2>/dev/null
}

if [ $# -lt 1 ]; then
    echo "Error: No command provided." >&2
    show_help >&2
    exit 2
fi

COMMAND="$1"
shift

case "$COMMAND" in
    system)
        cmd_system
        ;;
    network)
        cmd_network "$@"
        ;;
    disk)
        cmd_disk
        ;;
    help)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'" >&2
        show_help >&2
        exit 2
        ;;
esac
