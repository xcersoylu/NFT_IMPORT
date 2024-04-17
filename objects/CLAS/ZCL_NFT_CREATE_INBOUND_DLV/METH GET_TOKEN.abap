  METHOD get_token.
    DATA lv_url TYPE string.
    lv_url = VALUE #(  mt_parameters[ parameterkey = 'TOKEN_URL' ]-value OPTIONAL ).
    DATA(lv_username) = VALUE #( mt_parameters[ parameterkey = 'USERNAME' ]-value OPTIONAL ).
    DATA(lv_password) = VALUE #( mt_parameters[ parameterkey = 'PASSWORD' ]-value OPTIONAL ).
    TRY.
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( lv_url ).
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_header_fields( VALUE #( (  name = 'Accept' value = 'application/json' )
                                                         (  name = 'X-CSRF-Token' value = 'Fetch' ) ) ).
        lo_web_http_request->set_authorization_basic(
          EXPORTING
            i_username = CONV #( lv_username )
            i_password = CONV #( lv_password )
        ).

        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>get ).
        lo_web_http_response->get_cookies(
          RECEIVING
            r_value = DATA(lt_cookies)
        ).
        mt_cookies = CORRESPONDING #( lt_cookies ).
        rv_token = mv_token = lo_web_http_response->get_header_field( EXPORTING i_name  = 'x-csrf-token' ).
      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error.
    ENDTRY.
  ENDMETHOD.