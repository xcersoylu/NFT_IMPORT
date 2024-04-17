  METHOD create_delivery.
    CONSTANTS lc_success_code TYPE i VALUE 201.
    DATA lv_url TYPE string.
    DATA lv_json_temp TYPE string.
    lv_url = VALUE #(  mt_parameters[ parameterkey = 'DELIVERY_URL' ]-value OPTIONAL ).
    DATA(lv_username) = VALUE #( mt_parameters[ parameterkey = 'USERNAME' ]-value OPTIONAL ).
    DATA(lv_password) = VALUE #( mt_parameters[ parameterkey = 'PASSWORD' ]-value OPTIONAL ).
    TRY.
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( lv_url ).
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_authorization_basic(
          EXPORTING
            i_username = CONV #( lv_username )
            i_password = CONV #( lv_password )
        ).
        IF iv_token IS NOT INITIAL.
          mv_token = iv_token.
        ENDIF.
        lo_web_http_request->set_header_fields( VALUE #( (  name = 'Accept' value = 'application/json' )
                                                         (  name = 'Content-Type' value = 'application/json' )
                                                         (  name = 'X-CSRF-Token' value = mv_token ) ) ).
        LOOP AT mt_cookies INTO DATA(ls_cookie).
          lo_web_http_request->set_cookie(
            EXPORTING
              i_name    = ls_cookie-name
              i_value   = ls_cookie-value
          ).
        ENDLOOP.
        lo_web_http_request->set_text(
          EXPORTING
            i_text   = iv_json
        ).

        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
        DATA(lv_response) = lo_web_http_response->get_text( ).
        lo_web_http_response->get_status(
          RECEIVING
            r_value = DATA(ls_status)
        ).
        IF ls_status-code = lc_success_code. "yaratıldı.
          DATA lv_json TYPE string.
          FIND '"DeliveryDocument":"' IN lv_response MATCH OFFSET DATA(lv_offset).
          lv_offset += 20.
          lv_json_temp = lv_response+lv_offset(*).
          FIND FIRST OCCURRENCE OF '"' IN lv_json_temp MATCH OFFSET DATA(lv_offset_2).
          rv_delivery = lv_json_temp(lv_offset_2).
          rv_delivery = |{ rv_delivery ALPHA = IN }|.
        ELSE.
        ENDIF.
      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
    ENDTRY.
  ENDMETHOD.