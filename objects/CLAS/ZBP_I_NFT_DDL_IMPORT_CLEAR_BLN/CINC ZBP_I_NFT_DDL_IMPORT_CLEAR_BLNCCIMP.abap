CLASS lhc_zi_nft_ddl_import_clear_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_nft_ddl_import_clear_blnc_i RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_clear_blnc_i RESULT result.

    METHODS continuepopup FOR MODIFY
      IMPORTING keys FOR ACTION zi_nft_ddl_import_clear_blnc_i~continuepopup RESULT result.
*    METHODS createsupplierinvoice FOR MODIFY
*      IMPORTING keys FOR ACTION zi_nft_ddl_import_clear_blnc_i~createsupplierinvoice.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_clear_1 IMPLEMENTATION.

  METHOD get_instance_features.

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD continuepopup.

    TYPES BEGIN OF ty_business_data.
    INCLUDE TYPE zcl_nft_supplier_invoice=>tys_a_supplier_invoice_type.
    TYPES to_suplr_invc_item_pur_ord TYPE zcl_nft_supplier_invoice=>tyt_a_suplr_invc_item_pur_or_2.
    TYPES to_supplier_invoice_item_g TYPE zcl_nft_supplier_invoice=>tyt_a_supplier_invoice_item__3.
    TYPES END OF ty_business_data.

    DATA: ls_supplier        TYPE ty_business_data,
          ls_supplier_return TYPE ty_business_data,
          lo_http_client     TYPE REF TO if_web_http_client,
          lo_client_proxy    TYPE REF TO /iwbep/if_cp_client_proxy,
          lo_request         TYPE REF TO /iwbep/if_cp_request_create,
          lo_response        TYPE REF TO /iwbep/if_cp_response_create,
          lt_header_pro      TYPE TABLE OF string,
          lt_gl_pro          TYPE TABLE OF string,
          lt_po_pro          TYPE TABLE OF string,
          lt_r005            TYPE TABLE OF znft_t_r005.

    READ ENTITIES OF zi_nft_ddl_import_clear_blnc_h IN LOCAL MODE
        ENTITY zi_nft_ddl_import_clear_blnc_i
          ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_selected_lines)
      FAILED failed.
    CHECK lt_selected_lines IS NOT INITIAL.
    READ TABLE keys INTO DATA(ls_key) INDEX 1.
    DATA(lv_company_code) = VALUE #( lt_selected_lines[ 1 ]-companycode OPTIONAL ).
    SELECT SINGLE * FROM znft_t_t011
                    WHERE bukrs = @lv_company_code
                    INTO @DATA(ls_parameter).
    SELECT
      FROM znft_t_parameter
      FIELDS *
      WHERE parametername = 'SUPPLIER_INVOICE'
      INTO TABLE @DATA(lt_parameters).

    SELECT
      FROM @lt_selected_lines AS selected_lines INNER JOIN znft_t_r005 AS r005 ON r005~companycode = selected_lines~companycode
                                                                              AND r005~accountingdocument = selected_lines~accountingdocument
                                                                              AND r005~fiscalyear = selected_lines~fiscalyear
                                                                              AND r005~accountingdocumentitem = selected_lines~accountingdocumentitem
     FIELDS r005~companycode as companycode,
            r005~accountingdocument as accountingdocument,
            r005~fiscalyear as fiscalyear,
            r005~accountingdocumentitem as accountingdocumentitem,
            MAX( r005~referenceitem ) as referenceitem
     GROUP BY r005~companycode, r005~accountingdocument, r005~fiscalyear, r005~accountingdocumentitem
     ORDER BY r005~companycode, r005~accountingdocument, r005~fiscalyear, r005~accountingdocumentitem
     INTO TABLE @DATA(lt_r005_check).

    APPEND 'COMPANY_CODE' TO lt_header_pro.
    APPEND 'DOCUMENT_DATE' TO lt_header_pro.
    APPEND 'POSTING_DATE' TO lt_header_pro.
    APPEND 'SUPPLIER_INVOICE_IDBY_INVC' TO lt_header_pro.
    APPEND 'INVOICING_PARTY' TO lt_header_pro.
    APPEND 'DOCUMENT_CURRENCY' TO lt_header_pro.
    APPEND 'DOCUMENT_HEADER_TEXT' TO lt_header_pro.
    APPEND 'ACCOUNTING_DOCUMENT_TYPE' TO lt_header_pro.
    APPEND 'TAX_DETERMINATION_DATE' TO lt_header_pro.
    APPEND 'SUPPLIER_INVOICE_IS_CREDIT' TO lt_header_pro.
    APPEND 'PAYMENT_TERMS' TO lt_header_pro.

    APPEND 'SUPPLIER_INVOICE_ITEM' TO lt_gl_pro.
    APPEND 'DEBIT_CREDIT_CODE' TO lt_gl_pro.
    APPEND 'GLACCOUNT' TO lt_gl_pro.
    APPEND 'COMPANY_CODE' TO lt_gl_pro.
    APPEND 'TAX_CODE' TO lt_gl_pro.
    APPEND 'DOCUMENT_CURRENCY' TO lt_gl_pro.
    APPEND 'SUPPLIER_INVOICE_ITEM_AMOU' TO lt_gl_pro.

    APPEND 'SUPPLIER_INVOICE_ITEM' TO lt_po_pro.
    APPEND 'PURCHASE_ORDER' TO lt_po_pro.
    APPEND 'PURCHASE_ORDER_ITEM' TO lt_po_pro.
    APPEND 'DOCUMENT_CURRENCY' TO lt_po_pro.
    APPEND 'SUPPLIER_INVOICE_ITEM_AMOU' TO lt_po_pro.
    APPEND 'PURCHASE_ORDER_PRICE_UNIT' TO lt_po_pro.
    APPEND 'PURCHASE_ORDER_QUANTITY_UN' TO lt_po_pro.
    APPEND 'QUANTITY_IN_PURCHASE_ORDER' TO lt_po_pro.
    APPEND 'TAX_CODE' TO lt_po_pro.
    APPEND 'IS_SUBSEQUENT_DEBIT_CREDIT' TO lt_po_pro.

    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = VALUE #( lt_parameters[ parameterkey = 'COMM_SCENARIO' ]-value OPTIONAL )
                                                     comm_system_id = VALUE #( lt_parameters[ parameterkey = 'COMM_SYSTEM_ID' ]-value OPTIONAL )
                                                     service_id     = VALUE #( lt_parameters[ parameterkey = 'SERVICE_ID' ]-value OPTIONAL ) ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
          EXPORTING
             is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                 proxy_model_id      = 'ZNFT_SUPPLIER_INVOICE'
                                                 proxy_model_version = '0001' )
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV' ).
        ASSERT lo_http_client IS BOUND.
        LOOP AT lt_selected_lines INTO DATA(ls_selected_line).
          IF ls_selected_line-deliveryquantityunit = 'ST'.
            ls_selected_line-deliveryquantityunit = 'ADT'.
          ENDIF.
          CLEAR ls_supplier.
          ls_supplier =  VALUE #( company_code                = ls_selected_line-companycode
                                  document_date               = ls_key-%param-documentdate
                                  posting_date                = ls_key-%param-postingdate
                                  supplier_invoice_idby_invc  = ls_selected_line-accountingdocument && ls_selected_line-accountingdocumentitem
                                  invoicing_party             = ls_selected_line-supplier
                                  document_currency           = ls_selected_line-documentcurrency
                                  document_header_text        = ls_selected_line-deliverydocument && 'Dosya Kapama'
                                  accounting_document_type    = ls_parameter-blart
                                  tax_determination_date      = ls_selected_line-postingdate
                                  supplier_invoice_is_credit  = ''
                                  payment_terms = ls_parameter-zterm
                                 to_suplr_invc_item_pur_ord = VALUE #( ( supplier_invoice_item = '0001'
                                                                         purchase_order = ls_selected_line-referencesddocument
                                                                         purchase_order_item = ls_selected_line-referencesddocumentitem+1(*)
                                                                         document_currency = ls_selected_line-documentcurrency
                                                                         supplier_invoice_item_amou = ls_selected_line-documentcurrenyamount
                                                                         purchase_order_price_unit = ls_selected_line-deliveryquantityunit
                                                                         purchase_order_quantity_un = ls_selected_line-deliveryquantityunit
                                                                         quantity_in_purchase_order = ls_selected_line-deliveryquantity
                                                                         tax_code = ls_parameter-mwskz
                                                                         is_subsequent_debit_credit = ''  ) )
                                 to_supplier_invoice_item_g = VALUE #( ( supplier_invoice_item = '0001'
                                                                         debit_credit_code = 'H'
                                                                         glaccount = ls_selected_line-accountnumber
                                                                         company_code = ls_selected_line-companycode
                                                                         tax_code = ls_parameter-mwskz
                                                                         document_currency = ls_selected_line-documentcurrency
                                                                         supplier_invoice_item_amou = ls_selected_line-documentcurrenyamount ) )

                                 ).
          TRY.
              lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_SUPPLIER_INVOICE' )->create_request_for_create( ).
              DATA(lo_data_description_node) = lo_request->create_data_descripton_node( ).
              lo_data_description_node->set_properties( lt_header_pro  ).
              DATA(lo_item_child) = lo_data_description_node->add_child( 'TO_SUPLR_INVC_ITEM_PUR_ORD' ).
              lo_item_child->set_properties( lt_po_pro ).
              DATA(lo_item_child2) = lo_data_description_node->add_child( 'TO_SUPPLIER_INVOICE_ITEM_G' ).
              lo_item_child2->set_properties( lt_gl_pro ).
              lo_request->set_deep_business_data( is_business_data = ls_supplier
                                                  io_data_description = lo_data_description_node ).
              lo_response = lo_request->execute( ).
              lo_response->get_business_data( IMPORTING es_business_data = ls_supplier_return ).
            CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
              DATA(lv_error) = lx_remote->if_message~get_longtext(  ).
              DATA(lv_error_body) = lx_remote->http_error_body.
              DATA(ls_odata_error) = lx_remote->s_odata_error.
              DATA(lv_http_status_message) = lx_remote->http_status_message.
              APPEND VALUE #( %msg = new_message_with_text( text = lv_error
                                            severity = if_abap_behv_message=>severity-error ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
          ENDTRY.
          IF ls_supplier_return-supplier_invoice IS NOT INITIAL.
            read TABLE lt_r005_check INTO DATA(ls_r005_check) with key companycode = ls_selected_line-companycode
                                                                       accountingdocument = ls_selected_line-accountingdocument
                                                                       fiscalyear = ls_selected_line-fiscalyear
                                                                       accountingdocumentitem = ls_selected_line-accountingdocumentitem BINARY SEARCH.

            APPEND VALUE #( companycode             = ls_selected_line-companycode
                            accountingdocument      = ls_selected_line-accountingdocument
                            fiscalyear              = ls_selected_line-fiscalyear
                            accountingdocumentitem  = ls_selected_line-accountingdocumentitem
                            referenceitem           = ls_r005_check-referenceitem + 1
                            deliverydocument        = ls_selected_line-deliverydocument
                            deliverydocumentitem    = ls_selected_line-deliverydocumentitem
                            quantity                = ls_selected_line-deliveryquantity
                            quantityunit            = ls_selected_line-deliveryquantityunit
                            amount                  = ls_selected_line-documentcurrenyamount
                            currency                = ls_selected_line-documentcurrency
                            accountingdocument_inv  = ls_supplier_return-supplier_invoice
                            fiscalyear_inv          = ls_supplier_return-fiscal_year ) TO lt_r005.

            APPEND VALUE #( %msg = new_message( id = 'ZNFT_IMPORT_MC'
                                            number = 016
                                                v1 = ls_supplier_return-supplier_invoice
                                          severity = if_abap_behv_message=>severity-success ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
            FREE lo_request.
            FREE lo_item_child.
            FREE lo_item_child2.
            FREE lo_response.
            clear ls_r005_check.
          ENDIF.
        ENDLOOP.
        IF lt_r005 IS NOT INITIAL.
          MODIFY znft_t_r005 FROM TABLE @lt_r005.
        ENDIF.
      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        lv_error = lx_gateway->if_message~get_longtext(  ).
        APPEND VALUE #( %msg = new_message_with_text( text = lv_error
                                      severity = if_abap_behv_message=>severity-error ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        lv_error = lx_web_http_client_error->if_message~get_longtext(  ).
        APPEND VALUE #( %msg = new_message_with_text( text = lv_error
                                      severity = if_abap_behv_message=>severity-error ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
      CATCH cx_http_dest_provider_error INTO DATA(lx_provider_error).
        lv_error = lx_provider_error->if_message~get_longtext(  ).
        APPEND VALUE #( %msg = new_message_with_text( text = lv_error
                                      severity = if_abap_behv_message=>severity-error ) ) TO reported-zi_nft_ddl_import_clear_blnc_i.
    ENDTRY.
    READ ENTITIES OF zi_nft_ddl_import_clear_blnc_h IN LOCAL MODE
        ENTITY zi_nft_ddl_import_clear_blnc_i
          ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated)
      FAILED failed.
    result = VALUE #( FOR ls_updated IN lt_updated
       ( %tky   = ls_updated-%tky
         %param = ls_updated ) ).
  ENDMETHOD.

*  METHOD createsupplierinvoice.
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
*  ENDMETHOD.

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