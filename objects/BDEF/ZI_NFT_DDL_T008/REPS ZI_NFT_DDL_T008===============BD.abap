managed implementation in class zbp_i_nft_ddl_t008 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T008 //alias <alias_name>
persistent table znft_t_t008
lock master
authorization master ( instance )
//etag master <field_name>
{
  field( readonly : update ) Companycode , Costtype;
  create;
  update;
  delete;
  mapping for znft_t_t008
  {
    Companycode = companycode ;
    Costtype = costtype ;
    Calculationtype = calculationtype;
  }
}