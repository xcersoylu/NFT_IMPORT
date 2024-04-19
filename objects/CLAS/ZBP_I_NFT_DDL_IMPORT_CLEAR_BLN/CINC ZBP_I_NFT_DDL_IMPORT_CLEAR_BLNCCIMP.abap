CLASS lhc_zi_nft_ddl_import_clear_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZI_NFT_DDL_IMPORT_CLEAR_BLNC_I RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_NFT_DDL_IMPORT_CLEAR_BLNC_I RESULT result.

    METHODS ContinuePopup FOR MODIFY
      IMPORTING keys FOR ACTION ZI_NFT_DDL_IMPORT_CLEAR_BLNC_I~ContinuePopup RESULT result.

ENDCLASS.

CLASS lhc_zi_nft_ddl_import_clear_1 IMPLEMENTATION.

  METHOD get_instance_features.

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD ContinuePopup.
    READ ENTITIES OF zi_nft_ddl_import_clear_blnc_h IN LOCAL MODE
        ENTITY zi_nft_ddl_import_clear_blnc_i
          ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_selected_lines)
      FAILED failed.
    CHECK lt_selected_lines IS NOT INITIAL.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_NFT_DDL_IMPORT_CLEAR_BL DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_nft_ddl_import_clear_blnc_h RESULT result.

ENDCLASS.

CLASS lhc_ZI_NFT_DDL_IMPORT_CLEAR_BL IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_NFT_DDL_IMPORT_CLEAR_BL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_NFT_DDL_IMPORT_CLEAR_BL IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.