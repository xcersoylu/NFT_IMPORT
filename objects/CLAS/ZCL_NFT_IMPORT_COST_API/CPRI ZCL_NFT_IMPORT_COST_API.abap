  PRIVATE SECTION.
    DATA: ls_request        TYPE znft_s_import_cost_api_request,
          ls_response       TYPE znft_s_import_cost_api_res, "znft_tt_cost_items,
          lc_header_content TYPE string VALUE 'content-type',
          lc_content_type   TYPE string VALUE 'text/json'.