  METHOD if_http_service_extension~handle_request.
    CONSTANTS lc_shipment TYPE znft_t_t002-ddtyp VALUE '1'.
    DATA lv_deliverydocument TYPE i_deliverydocument-deliverydocument.
    DATA lv_deliverydocumentitem TYPE i_deliverydocumentitem-deliverydocumentitem.
    DATA ls_delivery_custom_fields TYPE znft_t_dlv_cus.
    DATA lt_delivery_item_custom_fields TYPE TABLE OF znft_t_dlvit_cus.
    DATA ls_delivery_item_custom_fields TYPE znft_t_dlvit_cus.
    DATA(ls_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = ls_request_body CHANGING data = ms_request ).
*  kontroller
    IF line_exists( ms_request-item[ shipquantity = 0 ] ).
      MESSAGE ID mc_msgid
             TYPE 'E'
             NUMBER 017
             INTO DATA(lv_message).
      APPEND lv_message TO ms_response-messages.
    ELSE.
      SELECT poitem~purchaseorder,
             poitem~purchaseorderitem,
             po~releaseisnotcompleted,
             po~purchasingcompletenessstatus,
             poitem~purchasingdocumentdeletioncode,
             poitem~iscompletelydelivered,
             poitem~invoiceisgoodsreceiptbased,
             poitem~supplierconfirmationcontrolkey
        FROM @ms_request-item AS item INNER JOIN i_purchaseorderitemapi01 AS poitem ON poitem~purchaseorder = item~purchaseorder
                                                                                   AND poitem~purchaseorderitem = item~purchaseorderitem
                                      INNER JOIN i_purchaseorderapi01 AS po ON po~purchaseorder = poitem~purchaseorder
     INTO TABLE @DATA(lt_poitemcheck).
*kontroller
      LOOP AT lt_poitemcheck INTO DATA(ls_poitemcheck).
        IF ls_poitemcheck-releaseisnotcompleted <> ''.
          CLEAR lv_message.
          MESSAGE ID mc_msgid
                 TYPE 'E'
                 NUMBER 010
                 WITH ls_poitemcheck-purchaseorder
                 INTO lv_message.
          APPEND lv_message TO ms_response-messages.
        ENDIF.

        IF ls_poitemcheck-purchasingcompletenessstatus <> ''.
          CLEAR lv_message.
          MESSAGE ID mc_msgid
                 TYPE 'E'
                 NUMBER 012
                 WITH ls_poitemcheck-purchaseorder
                 INTO lv_message.
          APPEND lv_message TO ms_response-messages.
        ENDIF.

        IF ls_poitemcheck-purchasingdocumentdeletioncode <> ''.
          CLEAR lv_message.
          MESSAGE ID mc_msgid
                 TYPE 'E'
                 NUMBER 011
                 WITH ls_poitemcheck-purchaseorder
                      ls_poitemcheck-purchaseorderitem
                 INTO lv_message.
          APPEND lv_message TO ms_response-messages.
        ENDIF.

        IF ls_poitemcheck-iscompletelydelivered <> ''.
          CLEAR lv_message.
          MESSAGE ID mc_msgid
                 TYPE 'E'
                 NUMBER 013
                 WITH ls_poitemcheck-purchaseorder
                      ls_poitemcheck-purchaseorderitem
                 INTO lv_message.
          APPEND lv_message TO ms_response-messages.
        ENDIF.

        IF ls_poitemcheck-invoiceisgoodsreceiptbased <> ''.
          CLEAR lv_message.
          MESSAGE ID mc_msgid
                 TYPE 'E'
                 NUMBER 014
                 WITH ls_poitemcheck-purchaseorder
                      ls_poitemcheck-purchaseorderitem
                 INTO lv_message.
          APPEND lv_message TO ms_response-messages.
        ENDIF.

        IF ls_poitemcheck-supplierconfirmationcontrolkey = ''.
          CLEAR lv_message.
          MESSAGE ID mc_msgid
                 TYPE 'E'
                 NUMBER 015
                 WITH ls_poitemcheck-purchaseorder
                      ls_poitemcheck-purchaseorderitem
                 INTO lv_message.
          APPEND lv_message TO ms_response-messages.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF ms_response-messages IS INITIAL.
      DATA(lv_date) = cl_abap_context_info=>get_system_date(  ).
      lv_deliverydocument = '00' && lv_date(4) && '%'.
      SELECT SINGLE MAX( deliverydocument )
                FROM znft_t_dlv_cus
                WHERE deliverydocument LIKE @lv_deliverydocument
                  AND documenttype = @lc_shipment
                  INTO @DATA(lv_max_deliverydocument).
      IF lv_max_deliverydocument IS INITIAL.
        lv_max_deliverydocument = '00' && lv_date(4) && '0000'.
      ELSE.
        lv_max_deliverydocument += 1.
        lv_max_deliverydocument = |{ lv_max_deliverydocument ALPHA = IN }|.
      ENDIF.
      ms_response-deliverydocument = lv_max_deliverydocument.
      DATA(ls_item) = VALUE #( ms_request-item[ 1 ] OPTIONAL ).
      ls_delivery_custom_fields = CORRESPONDING #( ms_request-header ).
      ls_delivery_custom_fields-deliverydocument = lv_max_deliverydocument.
      ls_delivery_custom_fields-companycode = ls_item-companycode.
      ls_delivery_custom_fields-documenttype = lc_shipment.
      LOOP AT ms_request-item INTO ls_item.
        ADD 10 TO lv_deliverydocumentitem.
        ls_delivery_item_custom_fields = CORRESPONDING #( ls_item MAPPING quantityunit = purchaseorderquantityunit ).
        ls_delivery_item_custom_fields-deliverydocument = lv_max_deliverydocument.
        ls_delivery_item_custom_fields-deliverydocumentitem = lv_deliverydocumentitem.
        APPEND ls_delivery_item_custom_fields TO lt_delivery_item_custom_fields.
      ENDLOOP.
      INSERT znft_t_dlv_cus FROM @ls_delivery_custom_fields.
      INSERT znft_t_dlvit_cus FROM TABLE @lt_delivery_item_custom_fields.

      CLEAR lv_message.
      MESSAGE ID mc_msgid
             TYPE 'S'
             NUMBER 003
             WITH lv_max_deliverydocument
             INTO lv_message.
      APPEND lv_message TO ms_response-messages.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.