projection;
strict ( 1 );

define behavior for ZC_NFT_DDL_IMPORT_CLEARENCE //alias <alias_name>
{
  use update;

  use association _POList { }
}

define behavior for ZC_NFT_DDL_IMPORT_PO_LIST_CLEA //alias <alias_name>
{
  use update;

  use action ClearencePopup;

  use association _Clearence;
}