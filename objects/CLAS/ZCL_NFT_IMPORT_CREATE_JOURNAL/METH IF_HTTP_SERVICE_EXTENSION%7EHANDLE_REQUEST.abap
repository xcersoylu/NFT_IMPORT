  METHOD if_http_service_extension~handle_request.
    DATA ls_r001 TYPE znft_t_r001.
    DATA lt_r002 TYPE TABLE OF znft_t_r002.
    DATA lt_je TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<fs_je>).
    TRY.
        <fs_je>-%cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH Cx_uuid_error INTO DATA(lx_error).
    ENDTRY.

    <fs_je>-%param = VALUE #( companycode                  = ms_request-header-companycode
                              documentreferenceid          = ms_request-header-documentreferenceid
                              createdbyuser                = sy-uname
                              businesstransactiontype      = 'RFBU'
                              accountingdocumenttype       = ms_request-header-accountingdocumenttype
                              documentdate                 = ms_request-header-documentdate
                              postingdate                  = ms_request-header-postingdate
                              accountingdocumentheadertext = ms_request-header-accountingdocumentheadertext
                              TaxDeterminationDate         = ms_request-header-taxdeterminationdate
                              ExchangeRateDate             = ms_request-header-exchangeratedate
                               _APItems = VALUE #( FOR wa_apitem IN ms_Request-apitem ( CORRESPONDING #( wa_apitem MAPPING _currencyamount = currencyamount ) ) )
                               _glitems = VALUE #( FOR wa_glitem IN ms_request-glitem ( CORRESPONDING #( wa_glitem MAPPING _currencyamount = currencyamount ) ) )
                               _TaxItems = VALUE #( FOR wa_taxitem IN ms_request-taxitem ( CORRESPONDING #( wa_taxitem MAPPING _currencyamount = currencyamount ) ) )
                            ).
    MODIFY ENTITIES OF i_journalentrytp
     ENTITY journalentry
     EXECUTE post FROM lt_je
     FAILED DATA(ls_failed)
     REPORTED DATA(ls_reported)
     MAPPED DATA(ls_mapped).
    IF ls_failed IS NOT INITIAL.
      ms_response-error_messages = VALUE #( FOR wa IN ls_reported-journalentry ( wa-%msg->if_message~get_text( ) ) ).
      response->set_status('400').
    ELSE.
      COMMIT ENTITIES BEGIN
       RESPONSE OF i_journalentrytp
       FAILED DATA(ls_commit_failed)
       REPORTED DATA(ls_commit_reported).
      COMMIT ENTITIES END.
      IF ls_commit_failed IS INITIAL.
        response->set_status('200').
        ms_response-accountingdocument = VALUE #( ls_commit_reported-journalentry[ 1 ]-AccountingDocument OPTIONAL ).
        ls_r001 = VALUE #( companycode           = ms_request-header-companycode
                           accountingdocument    = ms_response-accountingdocument
                           fiscalyear            = ms_request-header-documentdate(4)
                           costsource            = ms_request-header-costsource
                           vorgang               = ms_request-header-vorgang
                           automatictaxcalculate = ms_request-header-automatictaxcalculate
                           letterofcreditnumber  = ms_request-header-letterofcreditnumber
                           agencytotransfer      = ms_request-header-agencytotransfer ).
        lt_r002 = VALUE #( FOR wa_glitem2 IN ms_request-glitem ( companycode           = ms_request-header-companycode
                                                                 accountingdocument    = ms_response-accountingdocument
                                                                 fiscalyear            = ms_request-header-documentdate(4)
                                                                 costtype              = wa_glitem2-costtype
                                                                 deliverydocument      = wa_glitem2-deliverydocument
                                                                 deliverydocumentitem  = wa_glitem2-deliverydocumentitem
                                                                 documentcurrenyamount = wa_glitem2-documentcurrenyamount
                                                                 documentcurrency      = wa_glitem2-documentcurrenyamount
                                                                 accountnumber         = wa_glitem2-glaccount
                                                                 taxcode               = wa_glitem2-taxcode
                                                                 taxamount             = wa_glitem2-taxamount
                                                                 debitcreditindicator  = wa_glitem2-debitcreditindicator
                                                                 ) ).
        INSERT znft_t_r001 FROM @ls_r001.
        INSERT znft_t_r002 FROM TABLE @lt_r002.
      ELSE.

      ENDIF.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.