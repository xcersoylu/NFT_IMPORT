managed implementation in class zbp_i_nft_ddl_import_clear_bln unique;
strict ( 1 );

define behavior for ZI_NFT_DDL_IMPORT_CLEAR_BLNC_H //alias <alias_name>
with unmanaged save
lock master
authorization master ( instance )
{
  field ( readonly ) DeliveryDocument;
  association _item {  }
}

define behavior for ZI_NFT_DDL_IMPORT_CLEAR_BLNC_I //alias <alias_name>
with unmanaged save
lock dependent by _header
authorization dependent by _header
{
  field ( readonly ) deliverydocument , deliverydocumentitem, accountingdocument , companycode , fiscalyear , accountingdocumentitem ;
  action ( features : instance ) ContinuePopup parameter ZI_NFT_DDL_IMPORT_BLNC_popup result [1] $self;
  internal action CreateSupplierInvoice;
  association _header;
}