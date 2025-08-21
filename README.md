# simple-backup

Script interativo para backups simples usando [tar] para compactação e compressão de arquivos e [rsync] para sincronização incremental de diretórios, quando configurado. **O script não é projetado para ambientes de produção.**

## Como usar

### Requisitos

- Recomenda-se o Debian 11 ou superior (Testado no Debian 12.11).
- Permissões de root para executar o script.
- Pacotes como bzip2, xz-utils e rsync, ou acesso a internet para baixa-los.

### 1. Clone o repositório

```bash
git clone https://github.com/kurupt-on/simple-backup
cd simple-backup
```

### 2. Configure o backup

```bash
sudo ./setup.sh
```

- ATENÇÃO: O script não irá alertar se houver valores errados.

  - Menu principal:
    - **[R]**: Configure a sincronização de diretórios.
    - **[V]**: Mostra os valores definidos.
    - **[O]**: Mostra a opção extra.
    - **[F]**: Finaliza e aplica as configurções.
    - **[Q]**: Sai do script.
      
  - Comandos:
    - **[C]**: Define o algoritmo de compressão.
    - **[P]**: Define o caminho completo do backup.
    - **[E]**: Define um valor a opção "--exclude=" do tar.
    - **[A]**: Define os arquivos para o backup.
  
## Arquivos

- `README.md`: Este arquivo de documentação.
- `LICENSE`: Licença do projeto (MIT).
- `setup.sh`: Script princiçal de configuração.
- `backup/`: Se não definido um caminho diferente, será criado no diretório de execução do script para armazenar os backups.

## Licença

Este projeto está sob a licença MIT.
