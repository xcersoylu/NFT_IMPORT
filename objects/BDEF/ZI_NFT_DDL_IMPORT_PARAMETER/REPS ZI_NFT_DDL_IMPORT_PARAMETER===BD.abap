managed implementation in class zbp_i_nft_ddl_import_parameter unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_IMPORT_PARAMETER //alias <alias_name>
persistent table znft_t_parameter
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) ParameterName, ParameterKey;
}