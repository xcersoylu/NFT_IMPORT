managed implementation in class zbp_i_nft_ddl_t006 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T006 //alias <alias_name>
persistent table znft_t_t006
lock master
authorization master ( instance )
//etag master <field_name>
{
  field( readonly : update ) Vorgang;
  field( readonly : update ) Blart;
  create;
  update;
  delete;
  mapping for znft_t_t006
  {
    Vorgang = vorgang;
    Blart = blart ;
  }
}