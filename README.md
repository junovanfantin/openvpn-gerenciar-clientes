# openvpn-gerenciar-clientes

✅ Novos Recursos:
🔐 Criação automática de:

    Certificado com 10 anos.

    Arquivo .ovpn ou arquivos separados.

    Usuário do sistema Linux (com senha aleatória ou definida).
    

📦 Exportação:

    Todos os arquivos são exportados para /etc/openvpn/clientes/NOME_CLIENTE.

    Arquivos podem ser compactados em .zip automaticamente.
    

    🧪 Exemplo de uso
🔹 Gerar .ovpn com senha aleatória:
./gerenciar-cliente.sh -name LOJAXTZ -type ovpn

🔹 Gerar .ovpn com senha definida:
./gerenciar-cliente.sh -name LOJA123 -type ovpn -pass 123SenhaForte

🔹 Gerar arquivos separados:
./gerenciar-cliente.sh -name LOJA124 -type files


    🧪 Exemplos de uso
🔸 Criar certificado e gerar .ovpn:
./gerenciar-cliente.sh -name LOJAXTZ -type ovpn

🔸 Criar certificado e exportar arquivos separados:
./gerenciar-cliente.sh -name LOJAXTZ -type files

📂 Saída final

Estrutura de saída:
    /etc/openvpn/clientes/LOJAXTZ/
    
      ── LOJAXTZ.ovpn           (ou arquivos .crt/.key/.ca)
      ── README.txt             (contém a senha)
      ── LOJAXTZ.zip            ← ZIP final para envio ao cliente

❗ Dica: Configure corretamente o servidor OpenVPN

No /etc/openvpn/server.conf, garanta que tenha:
plugin /usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so login
client-cert-not-required
username-as-common-name

E reinicie o serviço:
sudo systemctl restart openvpn@server




