class ZCLJLM_DOWNLOAD definition
  public
  final
  create public .

public section.

  methods M_SET_FORMATO_ARQUIVO
    importing
      !I_FORMATO type ZEJLM_FORMATO_ARQUIVO .
  methods M_SET_TITULO_ARQUIVO
    importing
      !I_TITULO type STRING .
  methods M_SET_CAMINHO
    importing
      !I_CAMINHO type STRING .
  methods M_SET_CABECALHO
    importing
      !I_CABECALHO type TABNAME .
  methods M_SET_SEPARADOR
    importing
      !I_SEPARADOR type CHAR1 .
  methods M_SALVAR_ARQUIVO
    importing
      !I_ARQUIVO type STANDARD TABLE
      !I_LOCAL_SERVIDOR type ZEJLM_LOCAL_SERVIDOR .
  methods M_GET_MENSAGEM
    returning
      value(R_MENSAGEM) type BAPIRET2_T .
  PROTECTED SECTION.

    DATA v_formato TYPE zejlm_formato_arquivo .
    DATA v_separador TYPE char1 VALUE ';'.                "#EC NOTEXT .
    DATA v_cabecalho TYPE tabname .
    DATA v_caminho TYPE string .
    DATA v_titulo TYPE string .
    DATA it_mensagem TYPE bapiret2_t .
private section.

  methods M_SALVAR_TXT
    importing
      !I_ARQUIVO type STANDARD TABLE
      !I_LOCAL_SERVIDOR type ZEJLM_LOCAL_SERVIDOR .
  methods M_SALVAR_XML
    importing
      !I_ARQUIVO type STANDARD TABLE
      !I_LOCAL_SERVIDOR type ZEJLM_LOCAL_SERVIDOR .
  methods M_SALVAR_CSV
    importing
      !I_ARQUIVO type STANDARD TABLE
      !I_LOCAL_SERVIDOR type ZEJLM_LOCAL_SERVIDOR .
  methods M_DOWNLOAD_SERVIDOR
    importing
      !I_ARQUIVO type STANDARD TABLE .
  methods M_DOWNLOAD_LOCAL
    importing
      !I_ARQUIVO type STANDARD TABLE .
  methods M_FORMATAR_CAMINHO
    returning
      value(R_TITULO) type STRING .
  methods M_MONTAR_CABECALHO
    changing
      !CH_ARQUIVO type STANDARD TABLE .
ENDCLASS.



CLASS ZCLJLM_DOWNLOAD IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLJLM_DOWNLOAD->M_DOWNLOAD_LOCAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ARQUIVO                      TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_download_local.

    DATA: ol_root TYPE REF TO cx_root.

    DATA: wal_mensagem TYPE bapiret2.

    DATA: vl_filename TYPE string.

    vl_filename = m_formatar_caminho( ).

    TRY.
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            filename                = vl_filename
          TABLES
            data_tab                = i_arquivo
          EXCEPTIONS
            file_write_error        = 1
            no_batch                = 2
            gui_refuse_filetransfer = 3
            invalid_type            = 4
            no_authority            = 5
            unknown_error           = 6
            header_not_allowed      = 7
            separator_not_allowed   = 8
            filesize_not_allowed    = 9
            header_too_long         = 10
            dp_error_create         = 11
            dp_error_send           = 12
            dp_error_write          = 13
            unknown_dp_error        = 14
            access_denied           = 15
            dp_out_of_memory        = 16
            disk_full               = 17
            dp_timeout              = 18
            file_not_found          = 19
            dataprovider_exception  = 20
            control_flush_error     = 21
            OTHERS                  = 22.
        IF sy-subrc <> 0.
        wal_mensagem-id         = sy-msgid.
        wal_mensagem-type       = 'E'.
        wal_mensagem-number     = sy-subrc.
        wal_mensagem-message    = 'Erro ao executar Download local'.
        wal_mensagem-message_v1 = sy-msgv1.
        wal_mensagem-message_v2 = sy-msgv2.
        wal_mensagem-message_v3 = sy-msgv3.
        wal_mensagem-message_v4 = sy-msgv4.
        APPEND wal_mensagem TO it_mensagem.
        ENDIF.
      CATCH cx_root INTO ol_root.
        wal_mensagem-id         = 'ROOT_GUIDOWNLOAD'.
        wal_mensagem-type       = 'E'.
        wal_mensagem-number     = '00' && sy-subrc.
        wal_mensagem-message    = ol_root->get_longtext( ).
        wal_mensagem-message_v1 = ol_root->get_text( ).
        APPEND wal_mensagem TO it_mensagem.
    ENDTRY.

  ENDMETHOD.                    "m_download_local


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLJLM_DOWNLOAD->M_DOWNLOAD_SERVIDOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ARQUIVO                      TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_download_servidor.

    DATA: ol_root TYPE REF TO cx_root.

    DATA: wal_mensagem TYPE bapiret2.

    DATA: vl_nome TYPE string.

    FIELD-SYMBOLS: <fsl_arquivo> TYPE any.

    SORT it_mensagem BY type.

    READ TABLE it_mensagem WITH KEY type = 'E' BINARY SEARCH TRANSPORTING NO FIELDS.

    CHECK sy-subrc IS NOT INITIAL.

    vl_nome = m_formatar_caminho( ).

    TRY.
        IF v_formato = 'XML'.
          OPEN DATASET vl_nome FOR OUTPUT IN  BINARY MODE.
        ELSE.
          OPEN DATASET vl_nome FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
        ENDIF.

        LOOP AT i_arquivo ASSIGNING <fsl_arquivo>.

          TRANSFER <fsl_arquivo> TO vl_nome.

        ENDLOOP.

        CLOSE DATASET vl_nome.

      CATCH cx_root INTO ol_root.
        wal_mensagem-id         = 'ROOT_DATASET'.
        wal_mensagem-type       = 'E'.
        wal_mensagem-number     = '00' && sy-subrc.
        wal_mensagem-message    = ol_root->get_longtext( ).
        wal_mensagem-message_v1 = ol_root->get_text( ).
        APPEND wal_mensagem TO it_mensagem.
    ENDTRY.


  ENDMETHOD.                    "m_download_servidor


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLJLM_DOWNLOAD->M_FORMATAR_CAMINHO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] R_TITULO                       TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_formatar_caminho.

    r_titulo = v_caminho && '/' && v_titulo && '.' && v_formato.

  ENDMETHOD.                    "M_FORMATAR_CAMINHO


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLJLM_DOWNLOAD->M_GET_MENSAGEM
* +-------------------------------------------------------------------------------------------------+
* | [<-()] R_MENSAGEM                     TYPE        BAPIRET2_T
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD m_get_mensagem.

  r_mensagem = it_mensagem.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLJLM_DOWNLOAD->M_MONTAR_CABECALHO
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CH_ARQUIVO                     TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_montar_cabecalho.

    DATA: itl_campo TYPE lvc_t_fcat.

    DATA: wal_nome      TYPE string,
          wal_campos    TYPE lvc_s_fcat,
          wal_mensagem  TYPE bapiret2.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = v_cabecalho
      CHANGING
        ct_fieldcat      = itl_campo
      EXCEPTIONS
        OTHERS           = 1.

    IF sy-subrc = 0.

      LOOP AT itl_campo INTO wal_campos.

        IF wal_nome IS INITIAL.
          wal_nome = wal_campos-fieldname.
        ELSE.
          wal_nome = wal_nome && v_separador && wal_campos-fieldname.
        ENDIF.

      ENDLOOP.

      INSERT wal_nome INTO ch_arquivo INDEX 1.
    ELSE.
      wal_mensagem-type    = 'E'.
      wal_mensagem-number  = '00' && sy-subrc.
      wal_mensagem-message = 'Erro ao gerar cabeçalho'.
      APPEND wal_mensagem TO it_mensagem.
    ENDIF.

  ENDMETHOD.                    "m_montar_cabecalho


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLJLM_DOWNLOAD->M_SALVAR_ARQUIVO
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ARQUIVO                      TYPE        STANDARD TABLE
* | [--->] I_LOCAL_SERVIDOR               TYPE        ZEJLM_LOCAL_SERVIDOR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_salvar_arquivo.

    DATA vl_metodo TYPE string.

    vl_metodo = 'M_SALVAR_' && v_formato.

    CALL METHOD (vl_metodo)
      EXPORTING
        i_arquivo        = i_arquivo
        i_local_servidor = i_local_servidor.

  ENDMETHOD.                    "m_salvar_arquivo


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLJLM_DOWNLOAD->M_SALVAR_CSV
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ARQUIVO                      TYPE        STANDARD TABLE
* | [--->] I_LOCAL_SERVIDOR               TYPE        ZEJLM_LOCAL_SERVIDOR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_salvar_csv.

    DATA: ol_root TYPE REF TO cx_root.

    DATA: itl_arquivo TYPE truxs_t_text_data.

    DATA: wal_mensagem TYPE bapiret2.

    TRY.
        CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
          EXPORTING
            i_field_seperator    = v_separador
          TABLES
            i_tab_sap_data       = i_arquivo
          CHANGING
            i_tab_converted_data = itl_arquivo
          EXCEPTIONS
            conversion_failed    = 1
            OTHERS               = 2.
        IF sy-subrc <> 0.
          wal_mensagem-type    = 'E'.
          wal_mensagem-number  = '00' && sy-subrc.
          wal_mensagem-message = 'Erro ao Converter Arquivo CSV'.
          APPEND wal_mensagem TO it_mensagem.
        ELSE.

          IF v_cabecalho IS NOT INITIAL.
            m_montar_cabecalho( CHANGING ch_arquivo = itl_arquivo ).
          ENDIF.

          CASE i_local_servidor.
            WHEN 'S'.
              m_download_servidor( itl_arquivo ).
            WHEN 'L'.
              m_download_local( itl_arquivo ).
          ENDCASE.
        ENDIF.

      CATCH cx_root INTO ol_root.
        wal_mensagem-id         = 'ROOT_CSV'.
        wal_mensagem-type       = 'E'.
        wal_mensagem-number     = '00' && sy-subrc.
        wal_mensagem-message    = ol_root->get_longtext( ).
        wal_mensagem-message_v1 = ol_root->get_text( ).
        APPEND wal_mensagem TO it_mensagem.
    ENDTRY.

  ENDMETHOD.                    "M_SALVAR_CSV


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLJLM_DOWNLOAD->M_SALVAR_TXT
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ARQUIVO                      TYPE        STANDARD TABLE
* | [--->] I_LOCAL_SERVIDOR               TYPE        ZEJLM_LOCAL_SERVIDOR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_salvar_txt.

    DATA: ol_root TYPE REF TO cx_root.

    DATA: itl_arquivo TYPE truxs_t_text_data.

    DATA: wal_mensagem TYPE bapiret2.

    TRY.
        CALL FUNCTION 'SAP_CONVERT_TO_TXT_FORMAT'
          EXPORTING
            i_field_seperator    = v_separador
          TABLES
            i_tab_sap_data       = i_arquivo
          CHANGING
            i_tab_converted_data = itl_arquivo
          EXCEPTIONS
            conversion_failed    = 1
            OTHERS               = 2.
        IF sy-subrc <> 0.
          wal_mensagem-type    = 'E'.
          wal_mensagem-number  = '00' && sy-subrc.
          wal_mensagem-message = 'Erro ao Converter Arquivo TXT'.
          APPEND wal_mensagem TO it_mensagem.
        ELSE.
          CASE i_local_servidor.
            WHEN 'S'.
              m_download_servidor( itl_arquivo ).
            WHEN 'L'.
              m_download_local( itl_arquivo ).
          ENDCASE.
        ENDIF.
      CATCH cx_root INTO ol_root.
        wal_mensagem-id         = 'ROOT_TXT'.
        wal_mensagem-type       = 'E'.
        wal_mensagem-number     = '00' && sy-subrc.
        wal_mensagem-message    = ol_root->get_longtext( ).
        wal_mensagem-message_v1 = ol_root->get_text( ).
        APPEND wal_mensagem TO it_mensagem.
    ENDTRY.



  ENDMETHOD.                    "m_salvar_txt


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLJLM_DOWNLOAD->M_SALVAR_XML
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ARQUIVO                      TYPE        STANDARD TABLE
* | [--->] I_LOCAL_SERVIDOR               TYPE        ZEJLM_LOCAL_SERVIDOR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_salvar_xml.

    DATA: ol_root TYPE REF TO cx_root.

    DATA: itl_arquivo TYPE truxs_xml_table.

    DATA: wal_mensagem TYPE bapiret2.

    TRY.
        CALL FUNCTION 'SAP_CONVERT_TO_XML_FORMAT'
          EXPORTING
            i_field_seperator    = v_separador
          TABLES
            i_tab_sap_data       = i_arquivo
          CHANGING
            i_tab_converted_data = itl_arquivo
          EXCEPTIONS
            conversion_failed    = 1
            OTHERS               = 2.
        IF sy-subrc <> 0.
          wal_mensagem-type    = 'E'.
          wal_mensagem-number  = '00' && sy-subrc.
          wal_mensagem-message = 'Erro ao Converter Arquivo XML'.
          APPEND wal_mensagem TO it_mensagem.
        ELSE.
          CASE i_local_servidor.
            WHEN 'S'.
              m_download_servidor( itl_arquivo ).
            WHEN 'L'.
              m_download_local( itl_arquivo ).
          ENDCASE.
        ENDIF.

      CATCH cx_root INTO ol_root.
        wal_mensagem-id         = 'ROOT_XML'.
        wal_mensagem-type       = 'E'.
        wal_mensagem-number     = '00' && sy-subrc.
        wal_mensagem-message    = ol_root->get_longtext( ).
        wal_mensagem-message_v1 = ol_root->get_text( ).
        APPEND wal_mensagem TO it_mensagem.
    ENDTRY.

  ENDMETHOD.                    "M_SALVAR_XML


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLJLM_DOWNLOAD->M_SET_CABECALHO
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CABECALHO                    TYPE        TABNAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_set_cabecalho.

    v_cabecalho = i_cabecalho.

  ENDMETHOD.                    "m_set_cabecalho


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLJLM_DOWNLOAD->M_SET_CAMINHO
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CAMINHO                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_set_caminho.

    v_caminho = i_caminho.

  ENDMETHOD.                    "m_set_caminho


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLJLM_DOWNLOAD->M_SET_FORMATO_ARQUIVO
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_FORMATO                      TYPE        ZEJLM_FORMATO_ARQUIVO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_set_formato_arquivo.

    v_formato = i_formato.

  ENDMETHOD.                    "m_set_formato_arquivo


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLJLM_DOWNLOAD->M_SET_SEPARADOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_SEPARADOR                    TYPE        CHAR1
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_set_separador.

    v_separador = i_separador.

  ENDMETHOD.                    "m_set_separador


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLJLM_DOWNLOAD->M_SET_TITULO_ARQUIVO
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_TITULO                       TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD m_set_titulo_arquivo.

    v_titulo = i_titulo.

  ENDMETHOD.                    "m_set_titulo_arquivo
ENDCLASS.
