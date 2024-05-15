managed implementation in class zbp_i_nft_ddl_import_clearence unique;
//strict ( 1 );

define behavior for ZI_NFT_DDL_IMPORT_CLEARENCE //alias <alias_name>
with unmanaged save
lock master
authorization master ( instance )
//etag master <field_name>
{
  update;
  field ( readonly ) CompanyCode;
  association _POList { create; }
}

define behavior for ZI_NFT_DDL_IMPORT_PO_LIST_CLEA //alias <alias_name>
with unmanaged save
lock dependent by _Clearence
authorization dependent by _Clearence
//etag master <field_name>
{
  update;
  field ( readonly ) CompanyCode, PurchaseOrder, PurchaseOrderItem, Deliverydocument, deliverydocumentitem, Plant, StorageLocation,
  Material, MaterialText, MaterialGroup, MaterialGroupText, Batch, shipquantity,OrderQuantity,PurchaseOrderQuantityUnit,clearencequantity_max;
  action ( features : instance ) ClearencePopup parameter ZI_NFT_DDL_IMPORT_CLEA_POPUP result [1] $self;
  association _Clearence;
  validation ValidateClearenceQuantity on save { field clearencequantity;  }
  mapping for znft_t_clea_cus
    {
      deliverydocument          = deliverydocument;
      deliverydocumentitem      = deliverydocumentitem;
      ReferenceDocument         = referencedocument;
      ReferenceDocumentItem     = referencedocumentitem;
      incentivedocument         = incentivedocument;
      incentivedocumentitem     = incentivedocumentitem;
      controldocument           = controldocument;
      clearencequantity         = clearencequantity;
      PurchaseOrderQuantityUnit = quantityunit;
      invoicedocument           = invoicedocument;
      invoicedate               = invoicedate;
      gtipno                    = gtipno;
      origin                    = mensei;
    }
}