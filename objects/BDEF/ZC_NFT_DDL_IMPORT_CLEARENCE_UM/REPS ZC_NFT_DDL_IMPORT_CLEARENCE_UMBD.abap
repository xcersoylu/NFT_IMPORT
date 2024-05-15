projection;
strict ( 2 );

define behavior for ZC_NFT_DDL_IMPORT_CLEARENCE_UM //alias <alias_name>
{
  use update;

  use association _POList { }
}

define behavior for ZC_NFT_DDL_IMPORT_PO_CLEA_UM //alias <alias_name>
{
  use update;
  use action ClearencePopup;
  use association _Clearence;
}