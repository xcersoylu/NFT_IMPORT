managed implementation in class zbp_i_nft_ddl_t005 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T005 //alias <alias_name>
persistent table znft_t_t005
lock master
authorization master ( instance )
//etag master <field_name>
{
  field( readonly : update ) Csrce;
  field( readonly : update ) Ctype;
  create;
  update;
  delete;
  mapping for znft_t_t005
  {
    Csrce = csrce;
    Ctype = ctype;
  }
}