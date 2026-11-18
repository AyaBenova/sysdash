#!/usr/bin/env bash

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

system_monitor() {
    echo "System Monitor - A developper dans l'etape 2"
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


permissions_audit() {
    echo "Permissions Audit - A developper dans l'etape 4"
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
