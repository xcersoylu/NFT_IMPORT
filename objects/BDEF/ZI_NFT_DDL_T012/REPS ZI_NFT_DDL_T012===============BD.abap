managed implementation in class zbp_i_nft_ddl_t012 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T012 //alias <alias_name>
persistent table znft_t_t012
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Vorgang, Kalsm, Mwskz;
  mapping for znft_t_t012
    {
      Vorgang = vorgang;
      Kalsm   = kalsm;
      Mwskz   = mwskz;
    }
}