#!/bin/sh
set -e

show_tool_info() {
    tool_name="$1"
    repo_url="$2"
    description="$3"

    echo "-------------------------------------------------------------------"
    echo "Tool: $tool_name"
    echo "Source: $repo_url"
    echo "Description: $description"
    echo "Location: $(command -v "$tool_name" || echo 'not found in PATH')"
    echo
}

echo "==================================================================="
echo "Container utilities overview"
echo "==================================================================="
echo
echo "The following tools are installed in this image:"
echo
echo "  - ptt"
echo "  - rulechef"
echo "  - rulecat"
echo "  - hashcat-utils (*.bin, *.pl)"
echo
echo "Below is a brief overview and project links for each tool."
echo

show_tool_info "ptt" \
    "https://github.com/hashcracky/ptt" 

show_tool_info "rulechef" \
    "https://github.com/Cynosureprime/rulechef" 

show_tool_info "rulecat" \
    "https://github.com/Cynosureprime/rulecat" 

echo "-------------------------------------------------------------------"
echo "Hashcat-utils (binaries and Perl scripts)"
echo "Source: https://github.com/hashcat/hashcat-utils"
echo "Installed under /bin (e.g. combinator.bin, splitlen.bin, statsprocessor, *.pl)"
echo "Run them directly, for example:"
echo "  combinator.bin --help"
echo "  statsprocessor --help"
echo

echo "==================================================================="
echo "Runtime command"
echo "==================================================================="

if [ "$#" -eq 0 ]; then
    echo "No command was provided to the container."
    echo "To run a tool, pass it after the image name, for example:"
    echo
    echo "  docker run --rm your-image-name tool -h"
    echo
    echo "This container will now exit because no command was specified."
    exit 0
fi

echo "Executing user command:"
echo "  $*"
echo

exec "$@"
