managed implementation in class zbp_i_nft_ddl_t007 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T007 alias T007
persistent table znft_t_t007
lock master
authorization master ( instance )
//etag master <field_name>
{
  field( readonly : update ) bukrs;
  create;
  update;
  delete;
}