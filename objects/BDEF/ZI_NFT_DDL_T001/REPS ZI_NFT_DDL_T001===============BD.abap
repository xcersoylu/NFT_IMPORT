managed implementation in class zbp_i_nft_ddl_t001 unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_T001 //alias <alias_name>
persistent table znft_t_t001
lock master
authorization master ( instance )
//etag master <field_name>
{
  field ( readonly : update ) bsart;
  create;
  update;
  delete;
  association _T002 { create; }
  mapping for znft_t_t001
    {
      Bsart   = bsart;
      Bstae   = bstae;
    }
}

define behavior for ZI_NFT_DDL_T002 //alias <alias_name>
persistent table znft_t_t002
lock dependent by _T001
authorization dependent by _T001
//etag master <field_name>
{
  update;
  delete;
  field ( readonly ) Bsart;
  field ( readonly : update ) Ddtyp;
  association _T001;
  mapping for znft_t_t002
    {
      Bsart   = bsart;
      Ddtyp   = ddtyp;
      Lfart   = lfart;
      Gmpos   = gmpos;
    }
}