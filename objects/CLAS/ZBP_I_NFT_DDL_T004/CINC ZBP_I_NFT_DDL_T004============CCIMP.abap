CLASS lhc_ZI_NFT_DDL_T004 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_t004 RESULT result.

ENDCLASS.

CLASS lhc_ZI_NFT_DDL_T004 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.