#!/usr/bin/env bash
# =================================
# STEP 5 : ROBUSTNESS
# =================================

# 1. Error handling
handle_error() {
    echo "ERROR: An operation has failed."
}
# Check command exit status
check_status() {
    if [[ $? -ne 0 ]]; then
        handle_error
    fi
}
# 2. Clean exit
cleanup() {
    echo ""
    echo "Cleaning up..."
    echo "Sysdash terminated successfully."
}

# 3. Signal handling
handle_interrupt() {
    echo ""
    echo "Interrupt signal received."
    exit 130
}

# Register traps
trap cleanup EXIT
trap handle_interrupt INT TERM
# ==============================
# Sysdash - Tableau de bord système
# Etape 1 : Squelette
# ==============================

show_help() {
    echo "Usage: ./sysdash.sh [--help]"
    echo "Lancer le tableau de bord système."
}

show_menu() {
    echo ""
    echo "========== SYSDASH =========="
    echo "1. System Monitor"
    echo "2. Log Analysis"
    echo "3. Permissions Audit"
    echo "4. Help"
    echo "5. Exit"
    echo "============================"
}
# =================================
# STEP 2 : SYSTEM MONITOR
# =================================

# 1. CPU Usage
cpu_usage() {
    if ! read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; then
    handle_error
    return 1
fi

    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle1=$((idle + iowait))

    sleep 1

if ! read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; then
    handle_error
    return 1
fi

    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle2=$((idle + iowait))

    total_diff=$((total2 - total1))
    idle_diff=$((idle2 - idle1))
    busy=$((total_diff - idle_diff))

    awk -v busy="$busy" -v total="$total_diff" 'BEGIN {
        if (total > 0)
            printf "CPU Usage: %.2f%%\n", (busy / total) * 100
        else
            print "CPU Usage: 0%"
    }'
}

# 2. RAM Usage
ram_usage() {
    if ! read -r total < <(awk '/^MemTotal:/ {print $2}' /proc/meminfo); then
    handle_error
    return 1
fi
    if ! read -r available < <(awk '/^MemAvailable:/ {print $2}' /proc/meminfo); then
    handle_error
    return 1
fi

    used=$((total - available))

    awk -v used="$used" -v total="$total" 'BEGIN {
        if (total > 0)
            printf "RAM Usage: %.2f%%\n", (used / total) * 100
        else
            print "RAM Usage: 0%"
    }'
}

# 3. Load Average
load_average() {
    read -r load1 load5 load15 processes last_pid < /proc/loadavg

    echo "Load Average:"
    echo "1 minute:   $load1"
    echo "5 minutes:  $load5"
    echo "15 minutes: $load15"
    echo "Processes:  $processes"
}

# 4. Process Monitor
process_monitor() {
    echo "Top 5 Processes:"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
}

# 5. Main function (menu option 1)
system_monitor() {
    local stop=0
    trap 'stop=1' INT

    while [ "$stop" -eq 0 ]; do
        clear

        echo "===== SYSTEM MONITOR ====="
        echo

        cpu_usage
        echo

        ram_usage
        echo

        load_average
        echo

        process_monitor

        echo
        echo "Refreshing every 2 seconds..."
        echo "Press Ctrl+C to return to menu."

        sleep 2
    done

    trap handle_interrupt INT TERM
}
# ==============================
# STEP 3 : LOG ANALYSIS
# ==============================

log_analysis() {

    while true; do

        echo ""
        echo "========== LOG ANALYSIS =========="
        echo "1. Top IP Addresses"
        echo "2. HTTP 404 Errors"
        echo "3. Failed Authentication"
        echo "4. Back to Main Menu"
        echo "=================================="

        read -r -p "Votre choix : " log_choice

        case "$log_choice" in

            1)
                echo ""
                echo "===== TOP IP ADDRESSES ====="

                LOG_FILE=""

                if [[ -r /var/log/apache2/access.log ]]; then
                    LOG_FILE="/var/log/apache2/access.log"
                elif [[ -r /var/log/nginx/access.log ]]; then
                    LOG_FILE="/var/log/nginx/access.log"
                fi

                if [[ -n "$LOG_FILE" ]]; then
                    awk '{print $1}' "$LOG_FILE" |
                    sort |
                    uniq -c |
                    sort -nr |
                    head -10
                else
                    echo "No readable Apache or Nginx access log found."
                fi
                ;;

            2)
                echo ""
                echo "===== HTTP 404 ERRORS ====="

                LOG_FILE=""

                if [[ -r /var/log/apache2/access.log ]]; then
                    LOG_FILE="/var/log/apache2/access.log"
                elif [[ -r /var/log/nginx/access.log ]]; then
                    LOG_FILE="/var/log/nginx/access.log"
                fi

                if [[ -n "$LOG_FILE" ]]; then

                    echo "Total 404 errors:"

                    awk '$9 == 404 {count++} END {print count+0}' "$LOG_FILE"

                    echo ""
                    echo "Last 10 HTTP 404 requests:"

                    awk '$9 == 404 {print}' "$LOG_FILE" | tail -10

                else
                    echo "No readable access log found."
                fi
                ;;

            3)
                echo ""
                echo "===== FAILED AUTHENTICATION ====="

                AUTH_LOG=""

                if [[ -r /var/log/auth.log ]]; then
                    AUTH_LOG="/var/log/auth.log"
                elif [[ -r /var/log/secure ]]; then
                    AUTH_LOG="/var/log/secure"
                fi

                if [[ -n "$AUTH_LOG" ]]; then

                    echo "Total failed authentication attempts:"

                    grep -Eic 'Failed password|authentication failure|FAILED LOGIN' "$AUTH_LOG" || true

                    echo ""
                    echo "Last 10 failed authentication events:"

                    grep -Ei 'Failed password|authentication failure|FAILED LOGIN' "$AUTH_LOG" | tail -10

                else
                    echo "No readable authentication log found."
                fi
                ;;

            4)
                echo "Returning to main menu..."
                break
                ;;

            *)
                echo "Invalid choice. Try again."
                ;;

        esac

    done
}

# =================================
# STEP 4 : PERMISSIONS AUDIT
# =================================

permissions_audit() {

    while true; do

        echo ""
        echo "======= PERMISSIONS AUDIT ======="
        echo "1. Display /etc/passwd information"
        echo "2. Check sensitive file permissions"
        echo "3. Find SUID / SGID files"
        echo "4. Display current umask"
        echo "5. Back to Main Menu"
        echo "================================="

        read -r -p "Votre choix : " audit_choice

        case "$audit_choice" in

            1)
                echo ""
                echo "===== /etc/passwd INFORMATION ====="

                if [[ -r /etc/passwd ]]; then
                    echo "Username | UID | GID | Home | Shell"
                    awk -F: '{
                        printf "%-15s %-8s %-8s %-20s %s\n",
                        $1, $3, $4, $6, $7
                    }' /etc/passwd

                    echo ""
                    echo "Accounts with UID 0:"
                    awk -F: '$3 == 0 {
                        print $1
                    }' /etc/passwd
                else
                    echo "Cannot read /etc/passwd"
                fi
                ;;

            2)
                echo ""
                echo "===== SENSITIVE FILE PERMISSIONS ====="

                for file in /etc/passwd /etc/shadow /etc/group /etc/gshadow; do

                    if [[ -e "$file" ]]; then

                        mode=$(stat -c "%a" "$file")

                        echo ""
                        stat -c "%A %a %U:%G %n" "$file"

                        group_digit=${mode: -2:1}
                        other_digit=${mode: -1}

                        if (( (10#$group_digit & 2) != 0 || (10#$other_digit & 2) != 0 )); then
                            echo "WARNING: File is writable by group or others!"
                        else
                            echo "OK: No group/others write permission."
                        fi

                    else
                        echo "File not found: $file"
                    fi

                done
                ;;

            3)
                echo ""
                echo "===== SUID / SGID FILES ====="

                echo "SUID files:"
                find / -xdev -type f -perm -4000 -print 2>/dev/null

                echo ""
                echo "SGID files:"
                find / -xdev -type f -perm -2000 -print 2>/dev/null
                ;;

            4)
                echo ""
                echo "===== CURRENT UMASK ====="

                echo "Numeric umask:"
                umask

                echo ""
                echo "Symbolic umask:"
                umask -S

                echo ""
                echo "Default permissions:"
                echo "Files:       666 & ~umask"
                echo "Directories: 777 & ~umask"
                ;;

            5)
                echo "Returning to main menu..."
                break
                ;;

            *)
                echo "Invalid choice. Try again."
                ;;

        esac

    done
}

main() {

    if [[ "${1:-}" == "--help" ]]; then
        show_help
        exit 0
    fi

    while true; do

        show_menu

        read -r -p "Votre choix : " choice

        case "$choice" in
            1)
                system_monitor
                ;;
            2)
                log_analysis
                ;;
            3)
                permissions_audit
                ;;
            4)
                show_help
                ;;
            5)
                echo "Au revoir !"
                exit 0
                ;;
            *)
                echo "Choix invalide. Essayez encore."
                ;;
        esac

    done
}

main "$@"
