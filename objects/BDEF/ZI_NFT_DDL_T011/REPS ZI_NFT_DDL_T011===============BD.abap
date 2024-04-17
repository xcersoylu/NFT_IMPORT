managed implementation in class zbp_i_nft_ddl_t011 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T011 //alias <alias_name>
persistent table znft_t_t011
lock master
authorization master ( instance )
//etag master <field_name>
{
  field( readonly : update ) bukrs;
  create;
  update;
  delete;
  mapping for znft_t_t011
  {
   Bukrs = BUKRS ;
   Blart = BLART ;
   BlartTs = BLART_TS;
   Mwskz = MWSKZ ;
   Zterm = ZTERM ;
   Clrsh = CLRSH ;
  }
}