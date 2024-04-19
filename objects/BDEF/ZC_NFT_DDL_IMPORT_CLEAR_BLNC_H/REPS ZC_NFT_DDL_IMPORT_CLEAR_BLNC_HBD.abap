projection;
strict ( 2 );

define behavior for ZC_NFT_DDL_IMPORT_CLEAR_BLNC_H //alias <alias_name>
{

  use association _item;
}

define behavior for ZC_NFT_DDL_IMPORT_CLEAR_BLNC_I //alias <alias_name>
{
  use action ContinuePopup;
  use association _header;
}