  METHOD if_http_service_extension~handle_request.
    DATA lt_deliverydocument TYPE RANGE OF znft_e_vbeln.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).


    SELECT SINGLE companycode,
                  costsource,
                  vorgang,
                  automatictaxcalculate,
                  letterofcreditnumber,
                  agencytotransfer
    FROM znft_t_r001
    WHERE companycode = @ms_request-companycode
      AND accountingdocument = @ms_request-accountingdocument
      AND fiscalyear = @ms_request-fiscalyear
    INTO CORRESPONDING FIELDS OF @ms_response-header.
    IF sy-subrc = 0.
      SELECT SINGLE documentreferenceid,
                    accountingdocumenttype,
                    documentdate,
                    postingdate,
                    accountingdocumentheadertext,
*                   bkpf~taxdeterminationdate,
                    exchangeratedate
      FROM i_journalentry
      WHERE companycode = @ms_request-companycode
        AND accountingdocument = @ms_request-accountingdocument
        AND fiscalyear = @ms_request-fiscalyear
      INTO CORRESPONDING FIELDS OF @ms_response-header.
      SELECT 'I' AS sign,
             'EQ'  AS option,
             deliverydocument AS low
        FROM znft_t_r002
          WHERE companycode = @ms_request-companycode
           AND accountingdocument = @ms_request-accountingdocument
           AND fiscalyear = @ms_request-fiscalyear
        INTO CORRESPONDING FIELDS OF TABLE @lt_deliverydocument.

      SELECT
       FROM zi_nft_ddl_import_cost_data
       FIELDS deliverydocument,
              deliverydocumentitem,
              purchaseorder,
              purchaseorderitem,
              material,
              materialtext,
              deliveryquantity,
              salesunit,
              vendor,
              vendorname,
              orderquantity,
              documentcurrency,
              profitcenter,
              netvalue,
              unitofmeasure,
              netpriceamount,
              documenttype
        WHERE deliverydocument IN @lt_deliverydocument
        INTO CORRESPONDING FIELDS OF TABLE @ms_response-item.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).

  ENDMETHOD.