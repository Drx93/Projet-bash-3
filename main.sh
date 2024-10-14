#!/bin/bash

set_default_policies() {
    chain=0
    target=0

    while [ $chain -lt 1 ] || [ $chain -gt 3 ]; do
        echo -e "Quelle chaîne ? \n  1: INPUT \n  2: OUTPUT \n  3: FORWARD"
        read chain
        if [ $chain -lt 1 ] || [ $chain -gt 3 ]; then
            echo "Entrez un nombre valide"
        fi
    done

    while [ $target -lt 1 ] || [ $target -gt 3 ]; do
        echo -e "Quelle cible ? \n  1: ACCEPT \n  2: DROP \n  3: REJECT"
        read target
        if [ $target -lt 1 ] || [ $target -gt 3 ]; then
            echo "Entrez un nombre valide"
        fi
    done

    
    case $chain in
        1) chain="INPUT" ;;
        2) chain="OUTPUT" ;;
        3) chain="FORWARD" ;;
    esac

    
    case $target in
        1) target="ACCEPT" ;;
        2) target="DROP" ;;
        3) target="REJECT" ;;
    esac

    echo "Vous avez choisi $chain et $target"

    iptables -P $chain $target
}

main() {
    script=0
    while true; do
        echo -e "Que voulez-vous faire ? \n  1: Configurer les politiques par défaut \n  2: Quitter"
        read script

        case $script in
            1)
                set_default_policies
                ;;
            2)
                echo "Sortie du script."
                exit 0
                ;;
            *)
                echo "Option invalide. Veuillez choisir 1 ou 2."
                ;;
        esac
    done
}

main
