#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Arte ASCII
echo -e "${CYAN}"
cat << "EOF"
   _____ _          _ _
  / ____| |        | | |
 | (___ | |__   ___| | |___
  \___ \| '_ \ / _ \ | / __|
  ____) | | | |  __/ | \__ \
 |_____/|_| |_|\___|_|_|___/
EOF
echo -e "${NC}"

# Sistema Operacional
get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        sw_vers -productName && sw_vers -productVersion
    elif [ -f "$PREFIX/bin/termux-info" ]; then
        echo "Termux (Android)"
    else
        uname -o
    fi
}

get_kernel() {
    uname -r
}

get_shell() {
    echo "$SHELL"
}

get_uptime() {
    uptime -p | sed 's/up //'
}

get_cpu() {
    grep -m 1 'model name' /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ //'
}

get_memory() {
    free -h | awk '/Mem:/ {print $2 " total, " $3 " used, " $4 " free"}'
}

get_rom() {
    df -h / | awk 'NR==2 {print $2 " total, " $3 " used, " $4 " free"}'
}

get_bluetooth() {
    hciconfig | grep -i "hci" &>/dev/null && echo "Bluetooth Detectado" || echo "Bluetooth Não Detectado"
}

get_network() {
    ip -br a | grep UP | awk '{print $1 ": " $3}'
}

get_last_update() {
    if command -v stat &>/dev/null && [ -f /var/lib/apt/periodic/update-success-stamp ]; then
        stat /var/lib/apt/periodic/update-success-stamp | grep Modify
    elif [ -d /var/lib/pacman ]; then
        tail -n 1 /var/log/pacman.log | grep upgraded
    else
        echo "Indisponível"
    fi
}

get_datetime() {
    date
}

get_monitor() {
    if command -v xdpyinfo &>/dev/null; then
        xdpyinfo | grep dimensions | awk '{print $2}'
    else
        echo "xdpyinfo não disponível"
    fi
}

get_keyboard() {
    if command -v xinput &>/dev/null; then
        xinput list | grep -i "keyboard"
    else
        echo "xinput não disponível"
    fi
}

get_mouse() {
    if command -v xinput &>/dev/null; then
        xinput list | grep -i "mouse"
    else
        echo "xinput não disponível"
    fi
}

get_usb() {
    lsblk -o NAME,TRAN,MOUNTPOINT | grep usb || echo "Nenhum pendrive detectado"
}

get_packages() {
    if command -v pacman &> /dev/null; then
        pacman -Q | wc -l
    elif command -v dpkg &> /dev/null; then
        dpkg --list | grep '^ii' | wc -l
    elif command -v rpm &> /dev/null; then
        rpm -qa | wc -l
    else
        echo "N/A"
    fi
}

get_ip() {
    curl -s ifconfig.me
}

# Output final
echo
echo -e "${YELLOW}Usuário:${NC}   $USER"
echo -e "${YELLOW}Host:${NC}      $(hostname)"
echo -e "${YELLOW}Sistema Operacional:${NC} $(get_os)"
echo -e "${YELLOW}Kernel:${NC} $(get_kernel)"
echo -e "${YELLOW}Shell:${NC} $(get_shell)"
echo -e "${YELLOW}Uptime:${NC} $(get_uptime)"
echo -e "${YELLOW}CPU:${NC} $(get_cpu)"
echo -e "${YELLOW}RAM:${NC} $(get_memory)"
echo -e "${YELLOW}ROM (Disco):${NC} $(get_rom)"
echo -e "${YELLOW}Bluetooth:${NC} $(get_bluetooth)"
echo -e "${YELLOW}Interfaces de Rede:${NC}"; get_network
echo -e "${YELLOW}Última Atualização:${NC} $(get_last_update)"
echo -e "${YELLOW}Data e Hora:${NC} $(get_datetime)"
echo -e "${YELLOW}Tamanho do Monitor:${NC} $(get_monitor)"
echo -e "${YELLOW}Teclado:${NC}"; get_keyboard
echo -e "${YELLOW}Mouse:${NC}"; get_mouse
echo -e "${YELLOW}Pendrive conectado:${NC}"; get_usb
echo -e "${YELLOW}Pacotes:${NC}  $(get_packages)"
echo -e "${YELLOW}IP Público:${NC} $(get_ip)"
