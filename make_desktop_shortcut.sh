#!/usr/bin/env bash
set -euo pipefail

# Usage:
#         ./make-shortcut.share

# Description:
#         Interactive utility to generate .desktop entries in
#         ~/.local/share/applications for :
#         1) Terminal commands (simple commands only)
#         2) Browser shortcuts (opens URL in Firefox)

# Limitations:
#         - Terminal commands are not executed via a shell
#           (pipes, redirects, globbing will not work)

create_shortcut() {
        local type="$1"
        local name="$2"
        local exec_cmd="$3"
        local icon="$4"
        local terminal="$5"

        # Sanitize name for filename safety
        local safe_name
        safe_name="${name//\//_}"

        local desktop_dir="$HOME/.local/share/applications"
        local desktop_file="$desktop_dir/$safe_name.desktop"

        if [[ -e "$desktop_file" ]]; then
                echo "Error: shortcut '$safe_name' already exists."
                exit 1
        fi

        cat >"$desktop_file" <<EOF
[Desktop Entry]
Type=$type
Name=$name
Exec=$exec_cmd
Icon=$icon
Terminal=$terminal
Categories=Utility;
StartupNotify=true
EOF

        chmod +x "$desktop_file"
        echo "Application shortcut '$name' created at $desktop_file"
}

main() {
        echo "What kind of shortcut do you want to create?"
        echo "1. Terminal Command"
        echo "2. Browser Shortcut"

        read -r -p "Enter choice (1 or 2): " choice

        case "$choice" in
                1)
                        read -r -p "Enter the name of the shortcut: " name
                        read -r -p "Enter the command to execute: " command

                        read -r -p "Enter icon name (leave blank for default): " icon
                        icon="${icon:-terminal}"

                        create_shortcut \
                                "Application" \
                                "$name" \
                                "$command" \    # Cannot handle complex commands, pipes, quotes, etc.
                                "$icon" \
                                "true"
                        ;;
                2)
                        read -r -p "Enter the name of the browser shortcut: " name
                        read -r -p "Enter the URL to open: " url

                        read -r -p "Enter icon name (leave blank for firefox): " icon
                        icon="${icon:-firefox}"

                        create_shortcut \
                                "Application" \
                                "$name" \
                                "firefox \"$url\"" \
                                "$icon" \
                                "false"
                        ;;
                *)
                echo "Invalid choice. Exiting."
                exit 1
                ;;
        esac
}

# ========== INVOKE ==========
main
