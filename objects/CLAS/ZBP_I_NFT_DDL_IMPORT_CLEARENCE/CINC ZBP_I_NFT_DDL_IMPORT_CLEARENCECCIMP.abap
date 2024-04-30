CLASS lhc_zi_nft_ddl_import_clearenc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_clearence RESULT result.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_clearenc IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_po_list_ DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_nft_ddl_import_po_list_clea RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_po_list_clea RESULT result.

    METHODS clearencepopup FOR MODIFY
      IMPORTING keys FOR ACTION zi_nft_ddl_import_po_list_clea~clearencepopup RESULT result.
    METHODS validateclearencequantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_nft_ddl_import_po_list_clea~validateclearencequantity.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_po_list_ IMPLEMENTATION.

  METHOD get_instance_features.

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD clearencepopup.
    CONSTANTS lc_curly_braces_left TYPE c VALUE '{'.
    CONSTANTS lc_curly_braces_right TYPE c VALUE '}'.
    DATA lv_error TYPE string.
    DATA lv_json TYPE string.
    DATA lv_result TYPE string.
    DATA lt_delivery_custom_fields TYPE TABLE OF znft_t_dlv_cus.
    DATA ls_delivery_custom_fields TYPE znft_t_dlv_cus.
    DATA lt_delivery_item_custom_fields TYPE TABLE OF znft_t_dlvit_cus.
    DATA ls_delivery_item_custom_fields TYPE znft_t_dlvit_cus.
    DATA lv_posnr TYPE znft_e_posnr.
    READ ENTITIES OF zi_nft_ddl_import_clearence IN LOCAL MODE
        ENTITY zi_nft_ddl_import_po_list_clea
          ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_selected_lines)
      FAILED failed.
    CHECK lt_selected_lines IS NOT INITIAL.
    DATA(lo_create_delivery) = NEW zcl_nft_create_inbound_dlv(  ).
    DATA(lv_token) = lo_create_delivery->get_token(  ).
    IF  lv_token IS INITIAL.
      APPEND VALUE #( %msg = new_message( id       = 'ZNFT_IMPORT_MC'
                                          number   = '002'
                                          severity = if_abap_behv_message=>severity-error ) ) TO reported-zi_nft_ddl_import_po_list_clea.
    ELSE.
      SELECT *
      FROM znft_t_clea_cus
      FOR ALL ENTRIES IN @lt_selected_lines
      WHERE deliverydocument = @lt_selected_lines-deliverydocument
        AND deliverydocumentitem = @lt_selected_lines-deliverydocumentitem
      ORDER BY PRIMARY KEY
      INTO TABLE @DATA(lt_cus).
      DATA(lv_datum) = |{ cl_abap_context_info=>get_system_date(  ) DATE = ISO }T{ cl_abap_context_info=>get_system_time(  ) TIME = ISO }|.
      lv_json = lc_curly_braces_left .
      lv_json = |{ lv_json } "BillOfLading" : "",|.
      lv_json = |{ lv_json } "DeliveryDate" : "{ lv_datum }",|.
      lv_json = |{ lv_json } "to_DeliveryDocumentItem" : { lc_curly_braces_left } |.
      lv_json = |{ lv_json } "results" : [ |.
      DATA(lv_line_count) = lines( lt_selected_lines ).
      LOOP AT lt_selected_lines INTO DATA(ls_line).
        lv_line_count -= 1.
        lv_result = |{ lc_curly_braces_left }|.
        READ TABLE lt_cus INTO DATA(ls_cus) WITH KEY deliverydocument = ls_line-deliverydocument
                                                     deliverydocumentitem = ls_line-deliverydocumentitem BINARY SEARCH.
        IF sy-subrc = 0.
          lv_result = |{ lv_result } "ActualDeliveryQuantity": "{ ls_cus-clearencequantity }",|.
        ELSE.
          lv_result = |{ lv_result } "ActualDeliveryQuantity": "{ ls_line-clearencequantity }",|.
        ENDIF.
        lv_result = |{ lv_result } "DeliveryQuantityUnit": "{ ls_line-purchaseorderquantityunit }",|.
        lv_result = |{ lv_result } "ReferenceSDDocument": "{ ls_line-purchaseorder }",|.
        lv_result = |{ lv_result } "ReferenceSDDocumentItem": "{ ls_line-purchaseorderitem }" { lc_curly_braces_right } |.
        IF lv_line_count > 0.
          lv_json = |{ lv_json } { lv_result },|.
        ELSE.
          lv_json = |{ lv_json } { lv_result }|.
        ENDIF.
        CLEAR ls_cus.
      ENDLOOP.
      lv_json = |{ lv_json } ] { lc_curly_braces_right } { lc_curly_braces_right }|.
      lo_create_delivery->create_delivery(
        EXPORTING
          iv_json     = lv_json
        IMPORTING
          ev_error    = lv_error
        RECEIVING
          rv_delivery = DATA(lv_delivery)
      ).
      IF lv_delivery IS INITIAL.
        IF lv_error IS NOT INITIAL.
          APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text = lv_error ) ) TO reported-zi_nft_ddl_import_po_list_clea.
        ENDIF.
      ELSE.
*teslimat başarılı yaratıldı ise ara tablo temizleniyor.
        LOOP AT lt_cus INTO ls_cus.
          DELETE FROM znft_t_clea_cus WHERE deliverydocument = @ls_cus-deliverydocument
                                        AND deliverydocumentitem = @ls_cus-deliverydocumentitem.
        ENDLOOP.
        APPEND VALUE #( %msg = new_message( id       = 'ZNFT_IMPORT_MC'
                                            number   = '001'
                                            v1       = lv_delivery
                                            severity = if_abap_behv_message=>severity-success ) ) TO reported-zi_nft_ddl_import_po_list_clea.
        READ TABLE keys INTO DATA(ls_key) INDEX 1.
        ls_delivery_custom_fields = CORRESPONDING #( ls_key-%param ).
        ls_delivery_custom_fields-deliverydocument = lv_delivery.
        ls_delivery_custom_fields-companycode = ls_key-companycode.
        CLEAR lv_posnr.
        LOOP AT lt_selected_lines INTO DATA(ls_selected_line).
          lv_posnr += 10.
          ls_delivery_item_custom_fields = CORRESPONDING #( ls_selected_line EXCEPT shipquantity ).
          ls_delivery_item_custom_fields-deliverydocument = lv_delivery.
          ls_delivery_item_custom_fields-deliverydocumentitem = lv_posnr.
          ls_delivery_item_custom_fields-referencedocument = ls_selected_line-deliverydocument.
          ls_delivery_item_custom_fields-referencedocumentitem = ls_selected_line-deliverydocumentitem.
          READ TABLE lt_cus INTO ls_cus WITH KEY deliverydocument = ls_selected_line-deliverydocument
                                                       deliverydocumentitem = ls_selected_line-deliverydocumentitem BINARY SEARCH.
          IF sy-subrc = 0.
            ls_delivery_item_custom_fields-clearencequantity = ls_cus-clearencequantity.
          ELSE.
            ls_delivery_item_custom_fields-clearencequantity = ls_selected_line-clearencequantity.
          ENDIF.
          APPEND ls_delivery_item_custom_fields TO lt_delivery_item_custom_fields.
        ENDLOOP.
        IF ls_delivery_custom_fields IS NOT INITIAL.
          INSERT znft_t_dlv_cus FROM @ls_delivery_custom_fields.
          INSERT znft_t_dlvit_cus FROM TABLE @lt_delivery_item_custom_fields.
        ENDIF.
      ENDIF.
    ENDIF.
    READ ENTITIES OF zi_nft_ddl_import_clearence IN LOCAL MODE
    ENTITY zi_nft_ddl_import_po_list_clea
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_updated)
    FAILED failed.

    result = VALUE #( FOR ls_updated IN lt_updated
       ( %tky   = ls_updated-%tky
         %param = ls_updated ) ).
  ENDMETHOD.

  METHOD validateclearencequantity.
    READ ENTITIES OF zi_nft_ddl_import_clearence IN LOCAL MODE
    ENTITY zi_nft_ddl_import_po_list_clea
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_clearence_lines).
    LOOP AT lt_clearence_lines INTO DATA(ls_clearence_line).
      IF ls_clearence_line-shipquantity < ls_clearence_line-clearencequantity OR
         ls_clearence_line-clearencequantity_max < ls_clearence_line-clearencequantity.
        APPEND VALUE #( %tky = ls_clearence_line-%tky ) TO failed-zi_nft_ddl_import_po_list_clea.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message( id = 'ZNFT_IMPORT_MC'
                                            number = 004
                                            severity = if_abap_behv_message=>severity-error ) ) TO reported-zi_nft_ddl_import_po_list_clea.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_nft_ddl_import_clearenc DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_nft_ddl_import_clearenc IMPLEMENTATION.

  METHOD save_modified.
    IF update-zi_nft_ddl_import_po_list_clea IS NOT INITIAL.
      DATA lt_custom_fields TYPE TABLE OF znft_t_clea_cus.
      LOOP AT update-zi_nft_ddl_import_po_list_clea INTO DATA(ls_line).
        APPEND CORRESPONDING #( ls_line ) TO lt_custom_fields.
      ENDLOOP.
      IF  lt_custom_fields IS NOT INITIAL.
        MODIFY znft_t_clea_cus FROM TABLE @lt_custom_fields.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.