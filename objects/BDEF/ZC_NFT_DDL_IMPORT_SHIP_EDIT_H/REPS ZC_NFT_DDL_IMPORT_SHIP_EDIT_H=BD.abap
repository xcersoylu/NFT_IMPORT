projection;
strict ( 2 );

define behavior for ZC_NFT_DDL_IMPORT_SHIP_EDIT_H //alias <alias_name>
{
  use update;
  use delete;

  use association _item;
}

define behavior for ZC_NFT_DDL_IMPORT_SHIP_EDIT_I //alias <alias_name>
{
  use update;
  use delete;

  use association _header;
}