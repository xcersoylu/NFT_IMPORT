managed implementation in class zbp_i_nft_ddl_t010 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T010 //alias <alias_name>
persistent table znft_t_t010
lock master
authorization master ( instance )
//etag master <field_name>
{
  field(readonly : update) bukrs;
  field(readonly : update) bklas;
  field(readonly : update) ctype;
  create;
  update;
  delete;
  mapping for znft_t_t010
  {
    Bklas = bklas ;
    Bukrs = bukrs ;
    Ctype = ctype ;
    Saknr = saknr ;
    Trssk = trssk ;
  }
}