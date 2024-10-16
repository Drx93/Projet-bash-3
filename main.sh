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

configure_nat() {
    action=0
    
    while [ $action -lt 1 ] || [ $action -gt 2 ]; do
        echo -e "Que voulez-vous faire ? \n  1: Activer/Désactiver le NAT (Masquerade) \n  2: Gérer le port forwarding"
        read action
        if [ $action -lt 1 ] || [ $action -gt 2 ]; then
            echo "Entrez un nombre valide"
        fi
    done
    
    case $action in
        1) manage_nat_masquerade ;;
        2) manage_port_forwarding ;;
    esac
}

manage_nat_masquerade() {
    interface=""
    enable=0
    
    echo -e "Entrez l'interface réseau pour masquer le trafic (par exemple, eth0):"
    read interface
    
    while [ $enable -lt 1 ] || [ $enable -gt 2 ]; do
        echo -e "Voulez-vous activer ou désactiver le NAT ? \n  1: Activer \n  2: Désactiver"
        read enable
    done
    
    if [ $enable -eq 1 ]; then
        iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE
        echo "NAT activé sur l'interface $interface"
    else
        iptables -t nat -D POSTROUTING -o $interface -j MASQUERADE
        echo "NAT désactivé sur l'interface $interface"
    fi
}

manage_port_forwarding() {
    action=0
    while [ $action -lt 1 ] || [ $action -gt 2 ]; do
        echo -e "Que voulez-vous faire ? \n  1: Ajouter une règle de redirection de port \n  2: Supprimer une règle de redirection de port"
        read action
        if [ $action -lt 1 ] || [ $action -gt 2 ]; then
            echo "Entrez un nombre valide"
        fi
    done
    
    if [ $action -eq 1 ]; then
        add_port_forwarding
    else
        remove_port_forwarding
    fi
}

add_port_forwarding() {
    external_port=""
    internal_ip=""
    internal_port=""
    interface=""
    
    echo -e "Entrez le port externe à rediriger (par exemple, 80):"
    read external_port
    echo -e "Entrez l'adresse IP interne (par exemple, 192.168.1.100):"
    read internal_ip
    echo -e "Entrez le port interne à rediriger (par exemple, 8080):"
    read internal_port
    echo -e "Entrez l'interface réseau (par exemple, eth0):"
    read interface
    
    iptables -t nat -A PREROUTING -i $interface -p tcp --dport $external_port -j DNAT --to-destination $internal_ip:$internal_port
    iptables -A FORWARD -p tcp -d $internal_ip --dport $internal_port -j ACCEPT
    
    echo "Redirection du port $external_port vers $internal_ip:$internal_port ajoutée."
}

remove_port_forwarding() {
    external_port=""
    internal_ip=""
    internal_port=""
    interface=""
    
    echo -e "Entrez le port externe de la règle à supprimer:"
    read external_port
    echo -e "Entrez l'adresse IP interne de la règle à supprimer:"
    read internal_ip
    echo -e "Entrez le port interne de la règle à supprimer:"
    read internal_port
    echo -e "Entrez l'interface réseau:"
    read interface
    
    iptables -t nat -D PREROUTING -i $interface -p tcp --dport $external_port -j DNAT --to-destination $internal_ip:$internal_port
    iptables -D FORWARD -p tcp -d $internal_ip --dport $internal_port -j ACCEPT
    
    echo "Redirection du port $external_port vers $internal_ip:$internal_port supprimée."
}

main() {
    script=0
    
   
    while true; do
        echo -e "Que voulez-vous faire ? \n  1: Configurer les politiques par défaut \n  2: Configurer NAT (masquerade/port forwarding) \n  3: Quitter"
        read script
        
        case $script in
            1)
                set_default_policies
            ;;
            2)
                configure_nat
            ;;
            3)
                echo "Sortie du script."
                exit 0
            ;;
            *)
                echo "Option invalide. Veuillez choisir 1, 2 ou 3."
            ;;
        esac
    done
}

main