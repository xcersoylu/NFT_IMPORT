CLASS lhc_ZI_NFT_DDL_IMPORT_PARAMETE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_parameter RESULT result.

ENDCLASS.

CLASS lhc_ZI_NFT_DDL_IMPORT_PARAMETE IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.