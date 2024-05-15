unmanaged implementation in class zbp_i_nft_ddl_import_clea_um unique;
strict ( 2 );

define behavior for ZI_NFT_DDL_IMPORT_CLEARENCE_UM //alias <alias_name>
lock master
authorization master ( instance )
{
  update;
  field ( readonly ) CompanyCode;
  association _POList { }
}

define behavior for ZI_NFT_DDL_IMPORT_PO_CLEA_UM //alias <alias_name>
lock dependent by _Clearence
authorization dependent by _Clearence
{
  update;
  field ( readonly ) CompanyCode, PurchaseOrder, PurchaseOrderItem, Deliverydocument, deliverydocumentitem, Plant, StorageLocation,
  Material, MaterialText, MaterialGroup, MaterialGroupText, Batch, shipquantity,OrderQuantity,PurchaseOrderQuantityUnit,clearencequantity_max;
  association _Clearence;
  action ( features : instance ) ClearencePopup parameter ZI_NFT_DDL_IMPORT_CLEA_POPUP result [1] $self;
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