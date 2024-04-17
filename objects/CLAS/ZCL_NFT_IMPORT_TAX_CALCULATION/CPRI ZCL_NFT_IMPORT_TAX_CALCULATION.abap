  PRIVATE SECTION.
    DATA: ms_request   TYPE znft_s_import_tax_api_request,
          ms_response  TYPE znft_s_import_tax_api_response,
          mv_total_tax TYPE znft_e_bwert.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json',
               mc_Gross          TYPE znft_e_gross_net VALUE 'G',
               mc_net            TYPE znft_e_gross_net VALUE 'N'.
    METHODS calculate_tax IMPORTING is_line             TYPE znft_s_import_tax_line
                                    iv_calculation_Type TYPE znft_e_gross_net
                          RETURNING VALUE(rv_tax)       TYPE znft_e_bwert.