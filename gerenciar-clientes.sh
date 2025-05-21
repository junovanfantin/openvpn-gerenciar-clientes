#!/bin/bash

EASYRSA_DIR="/etc/openvpn/easy-rsa"  # Ajuste conforme sua instalação
cd "$EASYRSA_DIR" || { echo "❌ Easy-RSA não encontrado em $EASYRSA_DIR"; exit 1; }

source ./vars 2>/dev/null

CLIENT_NAME=""
OUTPUT_TYPE=""
KEYS_DIR="$EASYRSA_DIR/pki"
OUTPUT_DIR="/etc/openvpn/clientes"  # Onde os arquivos finais serão salvos
mkdir -p "$OUTPUT_DIR"

usage() {
    echo "Uso: $0 -name NOME_DO_CLIENTE -type [ovpn|files]"
    exit 1
}

# Processa os parâmetros
while [[ $# -gt 0 ]]; do
    case "$1" in
        -name)
            CLIENT_NAME="$2"
            shift 2
            ;;
        -type)
            OUTPUT_TYPE="$2"
            shift 2
            ;;
        *)
            echo "❌ Parâmetro inválido: $1"
            usage
            ;;
    esac
done

# Valida entrada
[[ -z "$CLIENT_NAME" || -z "$OUTPUT_TYPE" ]] && usage
[[ "$OUTPUT_TYPE" != "ovpn" && "$OUTPUT_TYPE" != "files" ]] && usage

# Verifica se o cliente já existe
if [[ -f "$KEYS_DIR/issued/${CLIENT_NAME}.crt" ]]; then
    echo "⚠️  O certificado para '$CLIENT_NAME' já existe. Abortando."
    exit 1
fi

# Cria o certificado (10 anos)
echo "🔐 Criando certificado de 10 anos para '$CLIENT_NAME'..."
./easyrsa build-client-full "$CLIENT_NAME" nopass

if [[ $? -ne 0 ]]; then
    echo "❌ Falha ao criar o certificado."
    exit 1
fi

# Geração de arquivos
if [[ "$OUTPUT_TYPE" == "files" ]]; then
    echo "📁 Gerando arquivos separados em: $OUTPUT_DIR/$CLIENT_NAME"
    mkdir -p "$OUTPUT_DIR/$CLIENT_NAME"
    cp "$KEYS_DIR/ca.crt" "$OUTPUT_DIR/$CLIENT_NAME/"
    cp "$KEYS_DIR/issued/$CLIENT_NAME.crt" "$OUTPUT_DIR/$CLIENT_NAME/"
    cp "$KEYS_DIR/private/$CLIENT_NAME.key" "$OUTPUT_DIR/$CLIENT_NAME/"
    echo "✅ Arquivos copiados."
elif [[ "$OUTPUT_TYPE" == "ovpn" ]]; then
    echo "📦 Gerando arquivo .ovpn único..."

    OVPN_TEMPLATE="$OUTPUT_DIR/$CLIENT_NAME.ovpn"

    cat > "$OVPN_TEMPLATE" <<EOF
client
dev tun
proto udp
remote SEU_ENDERECO_OU_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
verb 3

<ca>
$(cat "$KEYS_DIR/ca.crt")
</ca>

<cert>
$(openssl x509 -in "$KEYS_DIR/issued/$CLIENT_NAME.crt")
</cert>

<key>
$(cat "$KEYS_DIR/private/$CLIENT_NAME.key")
</key>
EOF

    echo "✅ Arquivo gerado: $OVPN_TEMPLATE"
fi
