CLASS lhc_zi_nft_ddl_import_det_main DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_nft_ddl_import_po_list RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_po_list RESULT result.

    METHODS DeliveryPopup FOR MODIFY
      IMPORTING keys FOR ACTION zi_nft_ddl_import_po_list~DeliveryPopup RESULT result.
    METHODS validateShipQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_nft_ddl_import_po_list~validateShipQuantity.
    METHODS DeleteQuantityTable FOR READ
      IMPORTING keys FOR FUNCTION zi_nft_ddl_import_po_list~DeleteQuantityTable RESULT result.
*    METHODS DefaultForDeliveryPopup FOR READ
*      IMPORTING keys FOR FUNCTION ZI_NFT_DDL_IMPORT_DET_MAIN~DefaultForDeliveryPopup RESULT result.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_det_main IMPLEMENTATION.

  METHOD get_instance_features.
*    READ ENTITIES OF ZI_NFT_DDL_IMPORT_SHIPMENT IN LOCAL MODE
*          ENTITY zi_nft_ddl_import_det_main
*            ALL FIELDS
*            WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_sas)
*        FAILED failed.
*    CHECK lt_sas IS NOT INITIAL.
*    result = VALUE #( FOR ls_sas in lt_sas ( %tky = ls_sas-%tky %action-DeliveryPopup =  if_abap_behv=>fc-o-enabled ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD DeliveryPopup.
*    delete from znft_t_dlv_cus.
*    delete from znft_t_dlvit_cus.
*    delete from znft_t_ship_cus.
*    delete from znft_t_clea_cus.
    CONSTANTS lc_shipment TYPE znft_t_t002-ddtyp VALUE '1'.
    DATA lv_deliverydocument TYPE I_Deliverydocument-deliverydocument.
    DATA lv_deliverydocumentitem TYPE I_Deliverydocumentitem-deliverydocumentitem.
    DATA lt_delivery_custom_fields TYPE TABLE OF znft_t_dlv_cus.
    DATA ls_delivery_custom_fields TYPE znft_t_dlv_cus.
    DATA lt_delivery_item_custom_fields TYPE TABLE OF znft_t_dlvit_cus.
    DATA ls_delivery_item_custom_fields TYPE znft_t_dlvit_cus.
    READ ENTITIES OF zi_nft_ddl_import_shipment IN LOCAL MODE
        ENTITY zi_nft_ddl_import_po_list
          ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_selected_lines)
      FAILED failed.
    CHECK lt_selected_lines IS NOT INITIAL.
    SELECT *
    FROM znft_t_ship_cus
    FOR ALL ENTRIES IN @lt_selected_lines
    WHERE purchaseorder = @lt_Selected_lines-PurchaseOrder
      AND purchaseorderitem = @lt_Selected_lines-PurchaseOrderItem
    ORDER BY PRIMARY KEY
    INTO TABLE @DATA(lt_cus).
    READ TABLE keys INTO DATA(ls_key) INDEX 1.
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
      ADD 1 TO lv_max_deliverydocument.
      lv_max_deliverydocument = |{ lv_max_deliverydocument ALPHA = IN }|.
    ENDIF.
    ls_delivery_custom_fields = CORRESPONDING #( ls_key-%param ).
    ls_Delivery_custom_fields-deliverydocument = lv_max_deliverydocument.
    ls_Delivery_custom_fields-companycode = ls_key-CompanyCode.
    ls_delivery_custom_fields-documenttype = lc_shipment.
    LOOP AT lt_selected_lines INTO DATA(ls_selected_line).
      ADD 10 TO lv_deliverydocumentitem.
      ls_delivery_item_custom_fields = CORRESPONDING #( ls_selected_line ).
      ls_delivery_item_custom_fields-deliverydocument = lv_max_deliverydocument.
      ls_delivery_item_custom_fields-deliverydocumentitem = lv_deliverydocumentitem.
      READ TABLE lt_cus INTO DATA(ls_cus) WITH KEY purchaseorder = ls_selected_line-PurchaseOrder
                                                   purchaseorderitem = ls_Selected_line-purchaseorderitem BINARY SEARCH.
      ls_delivery_item_custom_fields-shipquantity = ls_cus-shipquantity.
      APPEND ls_delivery_item_custom_fields TO lt_delivery_item_custom_fields.
    ENDLOOP.
    INSERT znft_t_dlv_cus FROM @ls_Delivery_custom_fields.
    INSERT znft_t_dlvit_cus FROM TABLE @lt_delivery_item_custom_fields.

    APPEND VALUE #( %msg = new_message( id       = 'ZNFT_IMPORT_MC'
                                        number   = '003'
                                        v1 = lv_max_deliverydocument
                                        severity = if_abap_behv_message=>severity-success ) ) TO reported-zi_nft_ddl_import_po_list.
*başarılı kaydedince ara tablo temizleniyor.
    LOOP AT lt_cus INTO ls_cus.
      DELETE FROM znft_t_ship_cus WHERE purchaseorder = @ls_cus-PurchaseOrder
                                    AND purchaseorderitem = @ls_cus-PurchaseOrderItem.
    ENDLOOP.

    READ ENTITIES OF zi_nft_ddl_import_shipment IN LOCAL MODE
    ENTITY zi_nft_ddl_import_po_list
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_updated)
    FAILED failed.

    result = VALUE #( FOR ls_updated IN lt_updated
       ( %tky   = ls_updated-%tky
         %param = ls_updated
         ) ).

  ENDMETHOD.

*  METHOD DefaultForDeliveryPopup.
*  ENDMETHOD.

  METHOD validateShipQuantity.
    READ ENTITIES OF zi_nft_ddl_import_shipment IN LOCAL MODE
    ENTITY zi_nft_ddl_import_po_list
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_shipment_lines).
    LOOP AT lt_shipment_lines INTO DATA(ls_shipment_line).
      IF ls_shipment_line-shipquantity > ls_shipment_line-orderquantity or
         ls_shipment_line-shipquantity > ls_shipment_line-shipquantity_max.
        APPEND VALUE #( %tky = ls_shipment_line-%tky ) TO failed-zi_nft_ddl_import_po_list.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message( id = 'ZNFT_IMPORT_MC'
                                            number = 005
                                            severity = if_abap_behv_message=>severity-error ) ) TO reported-zi_nft_ddl_import_po_list.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD DeleteQuantityTable.
    READ ENTITIES OF zi_nft_ddl_import_shipment IN LOCAL MODE
      ENTITY zi_nft_ddl_import_po_list
        ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_selected_lines).
    LOOP AT lt_Selected_lines INTO DATA(ls_selected_line).
      DELETE FROM znft_t_ship_cus WHERE purchaseorder = @ls_selected_line-PurchaseOrder
                                    AND purchaseorderitem = @ls_Selected_line-PurchaseOrderItem.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_NFT_DDL_IMPORT_SHIPMENT DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_shipment RESULT result.

ENDCLASS.

CLASS lhc_ZI_NFT_DDL_IMPORT_SHIPMENT IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_NFT_DDL_IMPORT_SHIPMENT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_NFT_DDL_IMPORT_SHIPMENT IMPLEMENTATION.

  METHOD save_modified.
    IF update-zi_nft_ddl_import_po_list IS NOT INITIAL.
      DATA lt_custom_fields TYPE TABLE OF znft_t_ship_cus.
      LOOP AT update-zi_nft_ddl_import_po_list INTO DATA(ls_line).
        APPEND CORRESPONDING #( ls_line ) TO lt_custom_fields.
      ENDLOOP.
      IF  lt_custom_fields IS NOT INITIAL.
        MODIFY znft_t_ship_cus FROM TABLE @lt_custom_fields.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.