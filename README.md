# openvpn-gerenciar-clientes

✅ Recursos novos:

    -name LOJAXTZ: você especifica o nome do cliente manualmente.

    -type ovpn: gera um único arquivo .ovpn.

    -type files: gera os arquivos separados (.crt, .key, .ca, etc.).

    Verifica se o cliente já existe antes de criar.

    Certificado válido por 10 anos (3650 dias).

🛠️ Como usar

    Salve o script como gerenciar-clientes.sh.

    Dê permissão de execução:

chmod +x gerenciar-clientes.sh

    Execute com:

./gerenciar-clientes.sh

🧪 Exemplos de uso
🔸 Criar certificado e gerar .ovpn:

./gerenciar-cliente.sh -name LOJAXTZ -type ovpn

🔸 Criar certificado e exportar arquivos separados:

./gerenciar-cliente.sh -name LOJAXTZ -type files

📁 Saídas

    Para -type ovpn:
    → /etc/openvpn/clientes/LOJAXTZ.ovpn

    Para -type files:
    → /etc/openvpn/clientes/LOJAXTZ/{ca.crt, LOJAXTZ.crt, LOJAXTZ.key}

🔧 Ajustes que você deve fazer:

    Substitua SEU_ENDERECO_OU_IP no template .ovpn pelo IP ou domínio público do seu servidor.

    Certifique-se de que o OpenVPN está usando a mesma CA e configuração.

