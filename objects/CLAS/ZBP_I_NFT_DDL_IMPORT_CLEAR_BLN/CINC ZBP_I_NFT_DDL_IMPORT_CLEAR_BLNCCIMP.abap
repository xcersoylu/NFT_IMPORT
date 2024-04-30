CLASS lhc_zi_nft_ddl_import_clear_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_nft_ddl_import_clear_blnc_i RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_clear_blnc_i RESULT result.

    METHODS continuepopup FOR MODIFY
      IMPORTING keys FOR ACTION zi_nft_ddl_import_clear_blnc_i~continuepopup RESULT result.
    METHODS createsupplierinvoice FOR MODIFY
      IMPORTING keys FOR ACTION zi_nft_ddl_import_clear_blnc_i~createsupplierinvoice.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_clear_1 IMPLEMENTATION.

  METHOD get_instance_features.

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD continuepopup.
    DATA:
      ls_header       TYPE zcl_nft_supplier_invoice=>tys_a_supplier_invoice_type,
      ls_glaccount    TYPE zcl_nft_supplier_invoice=>tys_a_supplier_invoice_item__3,
      ls_po           TYPE zcl_nft_supplier_invoice=>tys_a_suplr_invc_item_pur_or_2,
      lo_http_client  TYPE REF TO if_web_http_client,
      lo_client_proxy TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request      TYPE REF TO /iwbep/if_cp_request_create,
      lo_response     TYPE REF TO /iwbep/if_cp_response_create.
    data lv_url type string.
    READ ENTITIES OF zi_nft_ddl_import_clear_blnc_h IN LOCAL MODE
        ENTITY zi_nft_ddl_import_clear_blnc_i
          ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_selected_lines)
      FAILED failed.
    CHECK lt_selected_lines IS NOT INITIAL.
try.
    " Create http client
*DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
*                                             comm_scenario  = '<Comm Scenario>'
*                                             comm_system_id = '<Comm System Id>'
*                                             service_id     = '<Service Id>' ).
*lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
    lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
      EXPORTING
         is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                             proxy_model_id      = 'ZNFT_SUPPLIER_INVOICE'
                                             proxy_model_version = '0001' )
        io_http_client             = lo_http_client
        iv_relative_service_root   = '/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV' ).

    ASSERT lo_http_client IS BOUND.
    ls_header = VALUE #(
              company_code                = '1000'
              document_date               = '20240426'
              posting_date                = '20240426'
              supplier_invoice_idby_invc  = 'INV0001'
              invoicing_party             = '0001000000'
              document_currency           = 'TRY'
              document_header_text        = 'Cagatay Test'
              accounting_document_type    = 'RE'
              tax_determination_date      = '20240426'
              supplier_invoice_is_credit  = '' ).

    ls_glaccount = VALUE #(   supplier_invoice_item = '000001'
                               debit_credit_code = 'H'
                               glaccount = '0089901001'
                               company_code = '1000'
                               tax_code = 'V0'
                               document_currency = 'TRY'
                               supplier_invoice_item_amou = 57 ) .
    ls_po = VALUE #(  supplier_invoice_item = '000002'
                       purchase_order = '5500000003'
                       purchase_order_item = '00010'
                       document_currency = 'TRY'
                       supplier_invoice_item_amou = 57
                       purchase_order_price_unit = 'ST'
                       quantity_in_purchase_order = 1
                       tax_code = 'V0'
                       is_subsequent_debit_credit = ''  ).
    lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_SUPPLIER_INVOICE' )->create_request_for_create( ).
    lo_request->set_business_data( ls_header ).

    lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_SUPPLIER_INVOICE_ITEM_GL' )->create_request_for_create( ).
    lo_request->set_business_data( ls_glaccount ).

    lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_SUPLR_INVC_ITEM_PUR_ORD' )->create_request_for_create( ).
    lo_request->set_business_data( ls_po ).

    lo_response = lo_request->execute( ).

    " Get the after image
*lo_response->get_business_data( IMPORTING es_business_data = ls_business_data_return ).

  CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
    DATA(lv_error) = lx_remote->if_message~get_longtext(  ).

  CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
    lv_error = lx_gateway->if_message~get_longtext(  ).

  CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).

    RAISE SHORTDUMP lx_web_http_client_error.

ENDTRY.
*          MODIFY ENTITIES OF zi_nft_ddl_import_clear_blnc_h IN LOCAL MODE
*          ENTITY zi_nft_ddl_import_clear_blnc_i
*          EXECUTE  CreateSupplierInvoice FROM CORRESPONDING #( keys )
*          FAILED DATA(ls_failed)
*          REPORTED DATA(ls_reported)
*          MAPPED DATA(ls_mapped).

*    DATA ls_invoice TYPE STRUCTURE FOR ACTION IMPORT i_supplierinvoicetp~create.
*    DATA lt_invoice TYPE TABLE FOR ACTION IMPORT i_supplierinvoicetp~create.
*    READ ENTITIES OF zi_nft_ddl_import_clear_blnc_h IN LOCAL MODE
*        ENTITY zi_nft_ddl_import_clear_blnc_i
*          ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_selected_lines)
*      FAILED failed.
*    CHECK lt_selected_lines IS NOT INITIAL.
*    SELECT * FROM znft_t_t011 ORDER BY bukrs INTO TABLE @DATA(lt_parameters).
*    LOOP AT lt_selected_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
*      READ TABLE lt_parameters INTO DATA(ls_parameter) WITH KEY bukrs = <ls_line>-companycode BINARY SEARCH.
*      TRY.
*          ls_invoice-%cid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
*          ls_invoice-%param-supplierinvoiceiscreditmemo = abap_false.
*          ls_invoice-%param-accountingdocumenttype = ls_parameter-blart.
*          ls_invoice-%param-companycode = <ls_line>-companycode.
*          ls_invoice-%param-postingdate = cl_abap_context_info=>get_system_date(  ).
*          ls_invoice-%param-documentdate = cl_abap_context_info=>get_system_date(  ).
*          ls_invoice-%param-taxdeterminationdate = cl_abap_context_info=>get_system_date(  ).
*          ls_invoice-%param-documentcurrency = <ls_line>-documentcurrency.
*          ls_invoice-%param-supplierinvoiceidbyinvcgparty = 'INV0001'.
*          ls_invoice-%param-invoicingparty = '0001000000'.
*
*          ls_invoice-%param-_glitems = VALUE #( ( supplierinvoiceitem = '000001'
*                                                  debitcreditcode = cl_mmiv_rap_ext_c=>debitcreditcode-credit
*                                                  glaccount = '0089901001'
*                                                  companycode = <ls_line>-companycode
*                                                  taxcode = ls_parameter-mwskz
*                                                  documentcurrency = <ls_line>-documentcurrency
*                                                  supplierinvoiceitemamount = <ls_line>-documentcurrenyamount ) ).
*
*          ls_invoice-%param-_itemswithporeference = VALUE #( ( supplierinvoiceitem = '000002'
*                                                               purchaseorder = <ls_line>-referencesddocument
*                                                               purchaseorderitem = <ls_line>-referencesddocumentitem
*                                                               documentcurrency = <ls_line>-documentcurrency
*                                                               supplierinvoiceitemamount = <ls_line>-documentcurrenyamount
*                                                               purchaseorderquantityunit = 'ST'
*                                                               quantityinpurchaseorderunit = 1
*                                                               taxcode = ls_parameter-mwskz
*                                                               suplrinvcissubsqntdebitcrdt = '' ) ).
*
*          INSERT ls_invoice INTO TABLE lt_invoice.
*
*          MODIFY ENTITIES OF i_supplierinvoicetp
*          ENTITY supplierinvoice
*          EXECUTE create FROM lt_invoice
*          FAILED DATA(ls_failed)
*          REPORTED DATA(ls_reported)
*          MAPPED DATA(ls_mapped).
*          IF ls_failed IS NOT INITIAL.
*            DATA lo_message TYPE REF TO if_message.
*            LOOP AT ls_reported-supplierinvoice ASSIGNING FIELD-SYMBOL(<ls_error>).
*              IF <ls_error>-%msg->if_t100_dyn_msg~msgty = 'E'.
*                APPEND VALUE #( %msg = new_message( id = <ls_error>-%msg->if_t100_message~t100key-msgid
*                                                number = <ls_error>-%msg->if_t100_message~t100key-msgno
*                                                    v1 = <ls_error>-%msg->if_t100_dyn_msg~msgv1
*                                                    v2 = <ls_error>-%msg->if_t100_dyn_msg~msgv2
*                                                    v3 = <ls_error>-%msg->if_t100_dyn_msg~msgv3
*                                                    v4 = <ls_error>-%msg->if_t100_dyn_msg~msgv4
*                                              severity = CONV #( <ls_error>-%msg->if_t100_dyn_msg~msgty ) ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
*              ENDIF.
*            ENDLOOP.
*          ELSE.
*          ENDIF.
*
*        CATCH cx_uuid_error INTO DATA(lx_error).
*          DATA(lv_error) = lx_error->if_message~get_text(  ).
*          APPEND VALUE #( %msg = new_message_with_text( text = lv_error
*                                        severity = if_abap_behv_message=>severity-information ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
*      ENDTRY.
*    ENDLOOP.
ENDMETHOD.

METHOD createsupplierinvoice.
DATA ls_invoice TYPE STRUCTURE FOR ACTION IMPORT i_supplierinvoicetp~create.
DATA lt_invoice TYPE TABLE FOR ACTION IMPORT i_supplierinvoicetp~create.
READ ENTITIES OF zi_nft_ddl_import_clear_blnc_h IN LOCAL MODE
    ENTITY zi_nft_ddl_import_clear_blnc_i
      ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT DATA(lt_selected_lines)
  FAILED failed.
CHECK lt_selected_lines IS NOT INITIAL.
SELECT * FROM znft_t_t011 ORDER BY bukrs INTO TABLE @DATA(lt_parameters).
  LOOP AT lt_selected_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
    READ TABLE lt_parameters INTO DATA(ls_parameter) WITH KEY bukrs = <ls_line>-companycode BINARY SEARCH.
    TRY.
        ls_invoice-%cid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
        ls_invoice-%param-supplierinvoiceiscreditmemo = abap_false.
        ls_invoice-%param-accountingdocumenttype = ls_parameter-blart.
        ls_invoice-%param-companycode = <ls_line>-companycode.
        ls_invoice-%param-postingdate = cl_abap_context_info=>get_system_date(  ).
        ls_invoice-%param-documentdate = cl_abap_context_info=>get_system_date(  ).
        ls_invoice-%param-taxdeterminationdate = cl_abap_context_info=>get_system_date(  ).
        ls_invoice-%param-documentcurrency = <ls_line>-documentcurrency.
        ls_invoice-%param-supplierinvoiceidbyinvcgparty = 'INV0001'.
        ls_invoice-%param-invoicingparty = '0001000000'.

        ls_invoice-%param-_glitems = VALUE #( ( supplierinvoiceitem = '000001'
                                                debitcreditcode = cl_mmiv_rap_ext_c=>debitcreditcode-credit
                                                glaccount = '0089901001'
                                                companycode = <ls_line>-companycode
                                                taxcode = ls_parameter-mwskz
                                                documentcurrency = <ls_line>-documentcurrency
                                                supplierinvoiceitemamount = <ls_line>-documentcurrenyamount ) ).

        ls_invoice-%param-_itemswithporeference = VALUE #( ( supplierinvoiceitem = '000002'
                                                             purchaseorder = <ls_line>-referencesddocument
                                                             purchaseorderitem = <ls_line>-referencesddocumentitem
                                                             documentcurrency = <ls_line>-documentcurrency
                                                             supplierinvoiceitemamount = <ls_line>-documentcurrenyamount
                                                             purchaseorderquantityunit = 'ST'
                                                             quantityinpurchaseorderunit = 1
                                                             taxcode = ls_parameter-mwskz
                                                             suplrinvcissubsqntdebitcrdt = '' ) ).

        INSERT ls_invoice INTO TABLE lt_invoice.

        MODIFY ENTITIES OF i_supplierinvoicetp
        ENTITY supplierinvoice
        EXECUTE create FROM lt_invoice
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported)
        MAPPED DATA(ls_mapped).
        IF ls_failed IS NOT INITIAL.
          DATA lo_message TYPE REF TO if_message.
          LOOP AT ls_reported-supplierinvoice ASSIGNING FIELD-SYMBOL(<ls_error>).
            IF <ls_error>-%msg->if_t100_dyn_msg~msgty = 'E'.
              APPEND VALUE #( %msg = new_message( id = <ls_error>-%msg->if_t100_message~t100key-msgid
                                              number = <ls_error>-%msg->if_t100_message~t100key-msgno
                                                  v1 = <ls_error>-%msg->if_t100_dyn_msg~msgv1
                                                  v2 = <ls_error>-%msg->if_t100_dyn_msg~msgv2
                                                  v3 = <ls_error>-%msg->if_t100_dyn_msg~msgv3
                                                  v4 = <ls_error>-%msg->if_t100_dyn_msg~msgv4
                                            severity = CONV #( <ls_error>-%msg->if_t100_dyn_msg~msgty ) ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
            ENDIF.
          ENDLOOP.
        ELSE.
        ENDIF.

      CATCH cx_uuid_error INTO DATA(lx_error).
        DATA(lv_error) = lx_error->if_message~get_text(  ).
        APPEND VALUE #( %msg = new_message_with_text( text = lv_error
                                      severity = if_abap_behv_message=>severity-information ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
    ENDTRY.
  ENDLOOP.
ENDMETHOD.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_clear_bl DEFINITION INHERITING FROM cl_abap_behavior_handler.
PRIVATE SECTION.

  METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
    IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_clear_blnc_h RESULT result.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_clear_bl IMPLEMENTATION.

METHOD get_instance_authorizations.
ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_nft_ddl_import_clear_bl DEFINITION INHERITING FROM cl_abap_behavior_saver.
PROTECTED SECTION.

  METHODS save_modified REDEFINITION.

  METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_nft_ddl_import_clear_bl IMPLEMENTATION.

METHOD save_modified.

ENDMETHOD.

METHOD cleanup_finalize.

ENDMETHOD.

ENDCLASS.