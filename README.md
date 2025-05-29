
# 📦 COMPONENTE_DOWNLOAD_ARQUIVO

Este repositório contém um **componente ABAP** para realizar o download de arquivos, seja em diretórios **locais (cliente)** ou no **servidor SAP**, nos formatos **CSV**, **XML** e **TXT**. A solução é simples, flexível e pensada para facilitar a exportação de dados no formato desejado.

---

## 🎯 Funcionalidades

✅ Suporte aos formatos **CSV**, **XML** e **TXT**  
✅ Download para diretórios **locais** ou **servidor SAP**  
✅ Customização do separador e nome do arquivo  
✅ Componentização para fácil integração em outros programas  

---

## 📚 Exemplo de Implementação

```abap
DATA: itl_makt     TYPE makt_tab,
      itl_mensagem TYPE bapiret2_t,
      wal_makt     TYPE makt,
      vl_titulo    TYPE string,
      o_download   TYPE REF TO zcljlm_download.

" Prepara dados para exportação
wal_makt-mandt = sy-mandt.
wal_makt-spras = sy-langu.
wal_makt-maktx = 'Material de Teste'.
wal_makt-matnr = sy-datum.
APPEND wal_makt TO itl_makt.

" Cria título único para o arquivo
vl_titulo = 'UNIT_' && sy-datum && sy-uzeit.

" Cria instância do componente
CREATE OBJECT o_download.

" Configurações do download
o_download->m_set_cabecalho( 'MAKT' ).                " Define cabeçalho do arquivo
o_download->m_set_caminho( '/tmp' ).                  " Define caminho de salvamento
o_download->m_set_formato_arquivo( 'CSV' ).           " Define formato do arquivo
o_download->m_set_separador( ';' ).                   " Define separador de campos
o_download->m_set_titulo_arquivo( vl_titulo ).        " Define nome do arquivo

" Executa o download
o_download->m_salvar_arquivo( i_arquivo        = itl_makt
                              i_local_servidor = 'S' ).  " 'S' para servidor SAP

" Captura mensagens
itl_mensagem = o_download->m_get_mensagem( ).

```

---

## 💡 Observações

- O componente é flexível para exportar diferentes tabelas internas e formatos.
- A customização do cabeçalho, separador e nome do arquivo permite se adequar às necessidades do projeto.
- Ideal para relatórios ou processos que exigem exportação fácil e padronizada.

---

## 👤 Autor

Desenvolvido por [João Luís Medeiros](https://www.linkedin.com/in/joaoluismedeiros/)
