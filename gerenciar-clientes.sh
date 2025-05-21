#!/bin/bash

EASYRSA_DIR="/etc/openvpn/easy-rsa"  # ajuste conforme seu ambiente
cd "$EASYRSA_DIR" || { echo "Easy-RSA não encontrado em $EASYRSA_DIR"; exit 1; }

source ./vars 2>/dev/null

CLIENT_PREFIX="LOJA"
DAYS_VALID=3650  # 10 anos
KEYS_DIR="$EASYRSA_DIR/pki"

# Função para verificar se um usuário existe
verificar_usuario() {
    read -rp "Digite o nome do usuário (ex: LOJA001): " USERNAME
    if [[ -f "$KEYS_DIR/issued/${USERNAME}.crt" ]]; then
        echo "✅ O certificado do usuário '$USERNAME' já existe."
    else
        echo "❌ O certificado do usuário '$USERNAME' NÃO existe."
    fi
}

# Função para criar o próximo usuário incremental (LOJA001, LOJA002, etc)
criar_proximo_usuario() {
    echo "🔍 Procurando próximo nome disponível..."
    for i in $(seq -w 1 999); do
        USERNAME="${CLIENT_PREFIX}${i}"
        if [[ ! -f "$KEYS_DIR/issued/${USERNAME}.crt" ]]; then
            echo "📦 Próximo usuário disponível: $USERNAME"
            break
        fi
    done

    read -rp "Deseja criar certificado para '$USERNAME'? [s/N]: " CONFIRMA
    if [[ ! "$CONFIRMA" =~ ^[sS]$ ]]; then
        echo "❌ Cancelado."
        exit 0
    fi

    echo "🔐 Criando certificado de 10 anos para $USERNAME..."
    ./easyrsa build-client-full "$USERNAME" nopass

    if [[ $? -eq 0 ]]; then
        echo "✅ Certificado criado com sucesso: $USERNAME"
    else
        echo "❌ Erro ao criar certificado."
    fi
}

# Menu principal
echo "=========== GERENCIADOR DE CLIENTES OPENVPN ==========="
echo "1) Verificar se um usuário existe"
echo "2) Criar próximo usuário incremental"
echo "3) Sair"
read -rp "Escolha uma opção: " OPCAO

case "$OPCAO" in
    1) verificar_usuario ;;
    2) criar_proximo_usuario ;;
    *) echo "Saindo..." ;;
esac
