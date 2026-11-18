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

log_analysis() {
    echo "Log Analysis - A developper dans l'etape 3"
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
