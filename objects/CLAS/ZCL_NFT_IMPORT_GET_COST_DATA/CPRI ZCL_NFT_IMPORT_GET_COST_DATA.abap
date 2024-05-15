  PRIVATE SECTION.
    DATA: ms_request        TYPE znft_s_import_cost_data_req,
          ms_response       TYPE znft_s_import_cost_data_res, "znft_tt_cost_items,
          mc_header_content TYPE string VALUE 'content-type',
          mc_content_type   TYPE string VALUE 'text/json'.