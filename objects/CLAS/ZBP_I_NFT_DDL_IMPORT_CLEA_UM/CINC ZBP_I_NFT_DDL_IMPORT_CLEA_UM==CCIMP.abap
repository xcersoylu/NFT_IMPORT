CLASS lhc_zi_nft_ddl_import_clearenc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_clearence_um RESULT result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_nft_ddl_import_clearence_um.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_nft_ddl_import_clearence_um RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_nft_ddl_import_clearence_um.

    METHODS rba_polist FOR READ
      IMPORTING keys_rba FOR READ zi_nft_ddl_import_clearence_um\_polist FULL result_requested RESULT result LINK association_links.


ENDCLASS.

CLASS lhc_zi_nft_ddl_import_clearenc IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_polist.
  ENDMETHOD.


ENDCLASS.

CLASS lhc_zi_nft_ddl_import_po_clea_ DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_nft_ddl_import_po_clea_um.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_nft_ddl_import_po_clea_um RESULT result.

    METHODS rba_clearence FOR READ
      IMPORTING keys_rba FOR READ zi_nft_ddl_import_po_clea_um\_clearence FULL result_requested RESULT result LINK association_links.
    METHODS clearencepopup FOR MODIFY
      IMPORTING keys FOR ACTION zi_nft_ddl_import_po_clea_um~clearencepopup RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_nft_ddl_import_po_clea_um RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_po_clea_um RESULT result.
ENDCLASS.

CLASS lhc_zi_nft_ddl_import_po_clea_ IMPLEMENTATION.

  METHOD update.
    DATA lt_clea_cus TYPE TABLE OF znft_t_clea_cus.
    lt_clea_cus = CORRESPONDING #(  entities MAPPING FROM ENTITY ).
    zcl_nft_import_clea_um=>get_instance(  )->set_clea_cus( lt_clea_cus ).
  ENDMETHOD.

  METHOD read.
    SELECT * from zi_nft_ddl_import_po_clea_um
             FOR ALL ENTRIES IN @keys
             where companycode = @keys-CompanyCode
               and deliverydocument = @keys-deliverydocument
               and deliverydocumentitem = @keys-deliverydocumentitem
               into TABLE @data(lt_selected).
*    result = CORRESPONDING #( lt_selected MAPPING to ENTITY ).
  ENDMETHOD.

  METHOD rba_clearence.
  ENDMETHOD.

  METHOD clearencepopup.
    READ ENTITIES OF zi_nft_ddl_import_clearence_um IN LOCAL MODE
        ENTITY zi_nft_ddl_import_po_clea_um
          ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_selected_lines)
      FAILED failed.
    CHECK lt_selected_lines IS NOT INITIAL.
    zcl_nft_import_clea_um=>get_instance(  )->set_selected_lines( CORRESPONDING #( lt_selected_lines ) ).
    READ ENTITIES OF zi_nft_ddl_import_clearence_um IN LOCAL MODE
    ENTITY zi_nft_ddl_import_po_clea_um
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_updated)
    FAILED failed.
    result = VALUE #( FOR ls_updated IN lt_updated
       ( %tky   = ls_updated-%tky
         %param = ls_updated ) ).
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_nft_ddl_import_clearenc DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_nft_ddl_import_clearenc IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA lt_clea_cus TYPE TABLE OF znft_t_clea_cus.
    zcl_nft_import_clea_um=>get_instance(  )->get_clea_cus( IMPORTING et_clea_cus = lt_clea_cus ).
    IF lt_clea_cus IS NOT INITIAL.
      MODIFY znft_t_clea_cus FROM TABLE @lt_clea_cus.
    ENDIF.
**************************
    DATA lt_selected_lines TYPE TABLE OF zi_nft_ddl_import_po_clea_um.
    zcl_nft_import_clea_um=>get_instance(  )->get_selected_lines( IMPORTING et_selected_lines = lt_selected_lines ) .
    IF lt_selected_lines IS NOT INITIAL.

      DATA(ls_selected_lines) = VALUE zi_nft_ddl_import_po_clea_um( lt_selected_lines[ 1 ] OPTIONAL ).
      MODIFY ENTITIES OF i_inbounddeliverytp
          ENTITY inbounddelivery
        EXECUTE createdlvfrmpurchasingdocument
        FROM VALUE #( (  %cid = 'CREATE1'
                         %param = VALUE #( supplier = ls_selected_lines-supplier
                                          deliverydate = cl_abap_context_info=>get_system_date( )
                                          deliverytime = cl_abap_context_info=>get_system_time( )
                                          deliverydocumentbysupplier = 'Cagatay Test'
                                          meansoftransporttype = ''
                                          meansoftransport = ''
                          %control = VALUE #( supplier = if_abap_behv=>mk-on
                                              deliverydate = if_abap_behv=>mk-on
                                              deliverytime = if_abap_behv=>mk-on
                                              deliverydocumentbysupplier = if_abap_behv=>mk-on
                                              meansoftransporttype = if_abap_behv=>mk-on
                                              meansoftransport = if_abap_behv=>mk-on
                                              _referencepurgdocumentitem = if_abap_behv=>mk-on )
*                          _referencepurgdocumentitem = VALUE #( ( referencesddocument = '5500000000'
*                                                                  referencesddocumentitem = '00010'
*                                                                  %control = VALUE #( referencesddocument = if_abap_behv=>mk-on ) )
*                                                               (  referencesddocument = '5500000001'
*                                                                  referencesddocumentitem = '00010'
*                                                                  %control = VALUE #( referencesddocument = if_abap_behv=>mk-on ) )

                          _referencepurgdocumentitem = VALUE #( FOR wa IN lt_selected_lines ( referencesddocument = wa-purchaseorder
                                                                                              referencesddocumentitem = wa-purchaseorderitem
                                                                                              %control = VALUE #( referencesddocument = if_abap_behv=>mk-on ) )
                                                               ) ) ) )
            MAPPED DATA(mapped_create)
            REPORTED DATA(reported_create)
            FAILED DATA(failed_create).

*COMMIT ENTITIES BEGIN
*    RESPONSE OF I_InboundDeliveryTP
*    FAILED DATA(failed_save)
*  REPORTED DATA(reported_save).

      LOOP AT mapped_create-inbounddelivery ASSIGNING FIELD-SYMBOL(<mapped>).
*    IF failed_save IS INITIAL.
        CONVERT KEY OF i_inbounddeliverytp
                       FROM TEMPORARY VALUE #( %pid = <mapped>-%pid
                                               %tmp = <mapped>-%key ) TO DATA(lv_delivery).
        <mapped>-inbounddelivery = lv_delivery.
*    ENDIF.
      ENDLOOP.
*COMMIT ENTITIES END.

    ENDIF.
**************************
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.