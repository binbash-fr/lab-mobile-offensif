#!/bin/bash
# ============================================
# Lab Mobile Offensif — Script de déploiement
# Auteur : 946ctml
# Description : Déploiement automatique de
# l environnement d'analyse mobile offensif
# ============================================

set -e  # Stoppe si erreur

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err() { echo -e "${RED}[-]${NC} $1"; exit 1; }

log "Déploiement Lab Mobile Offensif"

# Vérification root
[ "$EUID" -ne 0 ] && err "Lance ce script en root"

# Mise à jour système
log "Mise à jour du système"
apt update -qq && apt upgrade -y -qq

# Installation dépendances
log "Installation des dépendances"
apt install -y -qq \
    python3 python3-pip \
    docker.io docker-compose \
    adb \
    wireshark \
    default-jdk \
    wget curl git

# Installation outils Python
log "Installation outils Python"
pip3 install frida-tools --break-system-packages --no-deps
pip3 install frida --break-system-packages


# Installation MobSF via Docker
log "Déploiement MobSF"
docker pull opensecurity/mobile-security-framework-mobsf:latest

# Démarrage MobSF
docker run -d \
    --name mobsf \
    -p 8000:8000 \
    opensecurity/mobile-security-framework-mobsf:latest

# Installation APKTool
log "Installation APKTool..."
apt install -y apktool
apktool --version && log "APKTool : OK ✓" || warn "APKTool : NOK"



# Vérification finale
log "Vérification des services"
docker ps | grep mobsf && log "MobSF : OK " || warn "MobSF : NOK"
frida --version && log "Frida : OK " || warn "Frida : NOK"
mitmproxy --version && log "mitmproxy : OK " || warn "mitmproxy : NOK"

log "Déploiement terminé"
log "MobSF disponible sur : http://localhost:8000"
