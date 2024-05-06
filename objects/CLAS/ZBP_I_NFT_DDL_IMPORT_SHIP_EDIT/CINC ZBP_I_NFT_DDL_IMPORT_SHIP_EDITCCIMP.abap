CLASS lhc_zi_nft_ddl_import_ship_edi DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_ship_edit_h RESULT result.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_ship_edi IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.