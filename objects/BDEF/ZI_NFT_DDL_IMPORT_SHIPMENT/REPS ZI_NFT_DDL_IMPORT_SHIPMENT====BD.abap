managed implementation in class zbp_i_nft_ddl_import_shipment unique;
strict ( 1 );

define behavior for ZI_NFT_DDL_IMPORT_SHIPMENT //alias <alias_name>
with unmanaged save
lock master
authorization master ( instance )
{
  //  create;
  update;
  //  delete;
  field ( readonly ) CompanyCode;
  association _POList { create; }
  association _DeliveryCustomFields { create; }
  association _DeliveryItemCustomFields { create; }
}

define behavior for ZI_NFT_DDL_IMPORT_PO_LIST //alias <alias_name>
with unmanaged save
lock dependent by _Shipment
authorization dependent by _Shipment
{
  update;
  field ( readonly ) CompanyCode, PurchaseOrder, PurchaseOrderItem, Plant, StorageLocation,
                     Material, MaterialText, MaterialGroup, MaterialGroupText, shipquantity_max,
                     Batch , OrderQuantity , PurchaseOrderQuantityUnit;
  static function DeleteQuantityTable result [1] $self;
  action ( features : instance ) DeliveryPopup parameter ZI_NFT_DDL_IMPORT_DLV_POPUP result [1] $self;  // { default function GetDefaultsForDeliveryPopup ; }
  association _Shipment;
  validation validateShipQuantity on save { field shipquantity ; }
  mapping for znft_t_ship_cus
    {
      PurchaseOrder         = purchaseorder;
      PurchaseOrderItem     = purchaseorderitem;
      ReferenceDocument     = referencedocument;
      ReferenceDocumentItem = referencedocumentitem;
      incentivedocument     = incentivedocument;
      incentivedocumentitem = incentivedocumentitem;
      controldocument       = controldocument;
      shipquantity          = shipquantity;
      PurchaseOrderQuantityUnit = quantityunit;
      netpr                 = netpr;
      peinh                 = peinh;
      netwr                 = netwr;
      currency              = currency;
      invoicedocument       = invoicedocument;
      invoicedate           = invoicedate;
      gtipno                = gtipno;
      mensei                = mensei;
    }
}
define behavior for ZI_NFT_DDL_IMPORT_DLV_CUS
persistent table znft_t_dlv_cus
lock dependent by _Shipment
authorization dependent by _Shipment
{
  field ( readonly ) CompanyCode, deliverydocument;
  association _Shipment;
  mapping for znft_t_dlv_cus
    {
      companycode                = companycode;
      deliverydocument           = deliverydocument;
      deliverydate               = deliverydate;
      meansoftransporttype       = meansoftransporttype;
      transportationplanningdate = transportationplanningdate;
      transportid                = transportid;
      loadingdate                = loadingdate;
      billoflading               = billoflading;
      documenttype               = documenttype;
      customsgate                = customsgate;
      customsreceivedate         = customsreceivedate;
      invoiceno                  = invoiceno;
      invoicedate                = invoicedate;
      fictitiousdeclerationdate  = fictitiousdeclerationdate;
      fictitiousdeclerationno    = fictitiousdeclerationno;
      customsdeclerationdate     = customsdeclerationdate;
      customsdeclerationno       = customsdeclerationno;
      importdate                 = importdate;
      insurancepolicynumber      = insurancepolicynumber;
      correspondencefilenumber   = correspondencefilenumber;
      currency                   = currency;
      valuationrate              = valuationrate;
      origin                     = origin;
    }
}

define behavior for ZI_NFT_DDL_IMPORT_DLV_IT_CUS
persistent table znft_t_dlvit_cus
lock dependent by _Shipment
authorization dependent by _Shipment
{
  field ( readonly ) CompanyCode, deliverydocument, deliverydocumentitem;
  association _Shipment;
  mapping for znft_t_dlvit_cus
    {
      companycode           = companycode;
      deliverydocument      = deliverydocument;
      deliverydocumentitem  = deliverydocumentitem;
      referencedocument     = referencedocument;
      referencedocumentitem = referencedocumentitem;
      incentivedocument     = incentivedocument;
      incentivedocumentitem = incentivedocumentitem;
      controldocument       = controldocument;
      shipquantity          = shipquantity;
      quantityunit          = quantityunit;
      netpr                 = netpr;
      peinh                 = peinh;
      netwr                 = netwr;
      currency              = currency;
      invoicedocument       = invoicedocument;
      invoicedate           = invoicedate;
      gtipno                = gtipno;
      origin                = origin;
    }
}