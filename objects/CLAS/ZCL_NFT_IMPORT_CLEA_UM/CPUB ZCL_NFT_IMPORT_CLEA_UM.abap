CLASS zcl_nft_import_clea_um DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES : tt_clea_cus TYPE TABLE OF znft_t_clea_cus.
    TYPES : tt_selected_lines TYPE TABLE OF zi_nft_ddl_import_po_clea_um.
    CLASS-METHODS get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_nft_import_clea_um.
    METHODS set_clea_cus IMPORTING it_clea_cus TYPE tt_clea_cus.
    METHODS get_clea_cus EXPORTING et_clea_cus TYPE tt_clea_cus.
    METHODS set_selected_lines IMPORTING it_selected_lines TYPE tt_selected_lines.
    METHODS get_selected_lines EXPORTING et_selected_lines TYPE tt_selected_lines.