projection;
strict ( 2 );

define behavior for ZC_NFT_DDL_T004 //alias <alias_name>
{
  use create;
  use update;
  use delete;

  use association _x004 { create; }
}

define behavior for ZC_NFT_DDL_X004 //alias <alias_name>
{
  use update;
  use delete;

  use association _t004;
}