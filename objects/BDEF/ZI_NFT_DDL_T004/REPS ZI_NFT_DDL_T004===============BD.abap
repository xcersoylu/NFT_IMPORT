managed implementation in class zbp_i_nft_ddl_t004 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T004 //alias <alias_name>
persistent table znft_t_t004
lock master
authorization master ( instance )
//etag master <field_name>
{
  field( readonly : update ) Ctype;
  create;
  update;
  delete;
  association _x004 { create; }
}

define behavior for ZI_NFT_DDL_X004 //alias <alias_name>
persistent table znft_t_x004
lock dependent by _t004
authorization dependent by _t004
//etag master <field_name>
{
  update;
  delete;
  field ( readonly ) Ctype;
  field ( readonly :update ) spras;
  association _t004;
}