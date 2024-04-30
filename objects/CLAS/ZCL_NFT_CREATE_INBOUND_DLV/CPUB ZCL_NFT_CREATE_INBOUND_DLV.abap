CLASS zcl_nft_create_inbound_dlv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA mt_cookies TYPE znft_tt_ihttpcki.
    DATA mv_token TYPE string.
    DATA mt_parameters TYPE TABLE OF znft_t_parameter.
    METHODS constructor.
    METHODS get_token RETURNING VALUE(rv_token) TYPE string.
    METHODS create_delivery IMPORTING iv_token           TYPE string OPTIONAL
                                      iv_json            TYPE string
                            EXPORTING
                                      ev_error           TYPE string
                            RETURNING VALUE(rv_delivery) TYPE znft_e_vbeln.