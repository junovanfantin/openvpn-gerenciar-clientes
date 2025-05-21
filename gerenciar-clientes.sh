#!/bin/bash

EASYRSA_DIR="/etc/openvpn/easy-rsa"
OUTPUT_DIR="/etc/openvpn/clientes"
cd "$EASYRSA_DIR" || { echo "❌ Easy-RSA não encontrado em $EASYRSA_DIR"; exit 1; }

source ./vars 2>/dev/null

CLIENT_NAME=""
OUTPUT_TYPE=""
USER_PASSWORD=""

KEYS_DIR="$EASYRSA_DIR/pki"
mkdir -p "$OUTPUT_DIR"

usage() {
    echo "Uso: $0 -name NOME_DO_CLIENTE -type [ovpn|files] [-pass SENHA]"
    echo "      -name   Nome do cliente (ex: LOJA001)"
    echo "      -type   Tipo de exportação: ovpn (arquivo único) ou files (arquivos separados)"
    echo "      -pass   (opcional) senha do usuário Linux; se omitido, será gerada automaticamente"
    exit 1
}

generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

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
        -pass)
            USER_PASSWORD="$2"
            shift 2
            ;;
        *)
            echo "❌ Parâmetro inválido: $1"
            usage
            ;;
    esac
done

[[ -z "$CLIENT_NAME" || -z "$OUTPUT_TYPE" ]] && usage
[[ "$OUTPUT_TYPE" != "ovpn" && "$OUTPUT_TYPE" != "files" ]] && usage

# Checagem se certificado já existe
if [[ -f "$KEYS_DIR/issued/${CLIENT_NAME}.crt" ]]; then
    echo "⚠️  O certificado '$CLIENT_NAME' já existe. Abortando."
    exit 1
fi

# Criação do certificado
echo "🔐 Criando certificado de 10 anos para '$CLIENT_NAME'..."
./easyrsa build-client-full "$CLIENT_NAME" nopass || {
    echo "❌ Falha ao criar certificado."
    exit 1
}

# Criação do usuário do sistema
if id "$CLIENT_NAME" &>/dev/null; then
    echo "ℹ️  Usuário '$CLIENT_NAME' já existe no sistema."
else
    if [[ -z "$USER_PASSWORD" ]]; then
        USER_PASSWORD=$(generate_password)
    fi
    useradd -m "$CLIENT_NAME"
    echo "$CLIENT_NAME:$USER_PASSWORD" | chpasswd
    echo "✅ Usuário Linux criado: $CLIENT_NAME"
    echo "🔑 Senha: $USER_PASSWORD"
fi

DEST_DIR="$OUTPUT_DIR/$CLIENT_NAME"
mkdir -p "$DEST_DIR"

if [[ "$OUTPUT_TYPE" == "files" ]]; then
    echo "📁 Exportando arquivos separados..."
    cp "$KEYS_DIR/ca.crt" "$DEST_DIR/"
    cp "$KEYS_DIR/issued/$CLIENT_NAME.crt" "$DEST_DIR/"
    cp "$KEYS_DIR/private/$CLIENT_NAME.key" "$DEST_DIR/"
    echo "🔑 Senha do usuário: $USER_PASSWORD" > "$DEST_DIR/README.txt"
    echo "✅ Arquivos exportados em: $DEST_DIR"

elif [[ "$OUTPUT_TYPE" == "ovpn" ]]; then
    echo "📦 Gerando arquivo .ovpn com autenticação por usuário/senha + certificado..."

    OVPN_TEMPLATE="$DEST_DIR/$CLIENT_NAME.ovpn"

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
auth SHA256
verb 3
auth-user-pass

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

    echo "🔑 Senha do usuário: $USER_PASSWORD" > "$DEST_DIR/README.txt"
    echo "✅ Arquivo .ovpn criado: $OVPN_TEMPLATE"
fi

# Geração de ZIP
echo "🗜️  Compactando para: $DEST_DIR.zip"
cd "$OUTPUT_DIR" && zip -rq "$CLIENT_NAME.zip" "$CLIENT_NAME"
echo "✅ Arquivo zip gerado: $OUTPUT_DIR/$CLIENT_NAME.zip"
