projection;
strict ( 1 );

define behavior for ZC_NFT_DDL_IMPORT_SHIPMENT //alias <alias_name>
{
  use update;
  use association _POList { }
  use association _DeliveryCustomFields { create; }
  use association _DeliveryItemCustomFields { create; }
}

define behavior for ZC_NFT_DDL_IMPORT_PO_LIST //alias <alias_name>
{
  use update;
  use action DeliveryPopup;
  use association _Shipment;
}

define behavior for ZC_NFT_DDL_IMPORT_DLV_CUS //alias <alias_name>
{
  use association _Shipment;
}

define behavior for ZC_NFT_DDL_IMPORT_DLV_IT_CUS //alias <alias_name>
{
  use association _Shipment;
}