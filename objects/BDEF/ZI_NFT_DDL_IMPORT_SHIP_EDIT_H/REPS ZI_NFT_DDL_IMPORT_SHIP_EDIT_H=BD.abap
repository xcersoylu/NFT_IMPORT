managed implementation in class zbp_i_nft_ddl_import_ship_edit unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_IMPORT_SHIP_EDIT_H //alias <alias_name>
persistent table znft_t_dlv_cus
lock master
authorization master ( instance )
//etag master <field_name>
{
  field ( readonly ) companycode, deliverydocument;
  update;
  delete;
  association _item { }

  mapping for znft_t_dlv_cus
    {
      companycode               = companycode;
      deliverydocument          = deliverydocument;
      deliverydate              = deliverydate;
      loadingdate               = loadingdate;
      billoflading              = billoflading;
      customsgate               = customsgate;
      customsreceivedate        = customsreceivedate;
      invoiceno                 = invoiceno;
      invoicedate               = invoicedate;
      fictitiousdeclerationdate = fictitiousdeclerationdate;
      fictitiousdeclerationno   = fictitiousdeclerationno;
      customsdeclerationdate    = customsdeclerationdate;
      customsdeclerationno      = customsdeclerationno;
      importdate                = importdate;
    }
}

define behavior for ZI_NFT_DDL_IMPORT_SHIP_EDIT_I //alias <alias_name>
persistent table znft_t_dlvit_cus
lock dependent by _header
authorization dependent by _header
//etag master <field_name>
{
  update;
  delete;
  field ( readonly ) companycode, deliverydocument, deliverydocumentitem, quantityunit;
  association _header;
  mapping for znft_t_dlvit_cus
    {
      companycode           = companycode;
      deliverydocument      = deliverydocument;
      deliverydocumentitem  = deliverydocumentitem;
      shipquantity          = shipquantity;
      quantityunit          = quantityunit;
      incentivedocument     = incentivedocument;
      incentivedocumentitem = incentivedocumentitem;
      controldocument       = controldocument;
      gtipno                = gtipno;
      origin                = origin;
    }
}