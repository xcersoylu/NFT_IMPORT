  PRIVATE SECTION.
    DATA: ms_request  TYPE znft_s_import_clea_create_req,
          ms_response TYPE znft_s_import_clea_create_res.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json'.