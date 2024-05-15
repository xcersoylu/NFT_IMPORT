  PRIVATE SECTION.
    DATA: ms_request  TYPE znft_s_import_shipment_req,
          ms_response TYPE znft_s_import_shipment_res.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json',
               mc_msgid          TYPE sy-msgid VALUE 'ZNFT_IMPORT_MC'.