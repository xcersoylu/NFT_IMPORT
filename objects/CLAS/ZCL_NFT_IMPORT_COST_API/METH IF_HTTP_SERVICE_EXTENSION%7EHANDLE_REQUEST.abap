  METHOD if_http_service_extension~handle_request.
    DATA lt_deliverydocument TYPE RANGE OF znft_e_vbeln.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).

    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ls_request ).
*    xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #( ( xco_cp_json=>transformation->pascal_case_to_underscore ) ) )->write_to( REF #( ls_req ) ).
    response->set_status('200').
    IF ls_request-deliverydocuments IS NOT INITIAL.
      lt_deliverydocument = VALUE #(  FOR wa IN ls_request-deliverydocuments ( sign = 'I' option = 'EQ'  low = |{ wa-deliverydocument ALPHA = IN }| ) ).
    ENDIF.
*    SELECT dlvm~deliverydocument,
*           dlvm~deliverydocumentitem,
*           dlvm~PurchaseOrder,
*           dlvm~purchaseorderitem,
*           dlvm~material,
*           dlvm~maktx AS materialtext,
*           dlvm~actualdeliveryquantity as deliveryquantity,
*           dlvm~DeliveryQuantityUnit as salesunit,
*           dlvm~Supplier as vendor,
*           dlvm~SupplierName as vendorname,
*           dlvm~orderquantity,
*           dlvm~DocumentCurrency,
*           dlvm~profitcenter,
*           dlvm~netwr as netvalue,
*           dlvm~PurchaseOrderQuantityUnit as unitofmeasure
*      FROM zi_nft_ddl_import_det_dlvm AS dlvm
*      WHERE dlvm~deliverydocument IN @lt_deliverydocument
*      INTO CORRESPONDING FIELDS OF TABLE @ls_response.
    SELECT
     FROM zi_nft_ddl_import_cost_data
     FIELDS DeliveryDocument,
            DeliveryDocumentItem,
            PurchaseOrder,
            PurchaseOrderItem,
            material,
            materialtext,
            deliveryquantity,
            salesunit,
            vendor,
            vendorname,
            orderQuantity,
            DocumentCurrency,
            ProfitCenter,
            Netvalue,
            Unitofmeasure,
            NetPriceAmount
      WHERE deliverydocument IN @lt_deliverydocument
      INTO CORRESPONDING FIELDS OF TABLE @ls_response.
    IF sy-subrc <> 0.
      APPEND VALUE #( deliverydocument = '1' ) TO ls_response.
      APPEND VALUE #( deliverydocument = '2' ) TO ls_response.
      APPEND VALUE #( deliverydocument = '3' ) TO ls_response.
      APPEND VALUE #( deliverydocument = '4' ) TO ls_response.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ls_response ).
*    DATA(lv_json_string) = xco_cp_json=>data->from_abap( 'Çağatay' )->apply( VALUE #(
*    ( xco_cp_json=>transformation->underscore_to_pascal_case )
*    ) )->to_string( ).

    response->set_text( lv_response_body ).
    response->set_header_field( i_name = lc_header_content i_value = lc_content_type ).


  ENDMETHOD.