CLASS lhc_ZI_NFT_DDL_T008 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_t008 RESULT result.

ENDCLASS.

CLASS lhc_ZI_NFT_DDL_T008 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.