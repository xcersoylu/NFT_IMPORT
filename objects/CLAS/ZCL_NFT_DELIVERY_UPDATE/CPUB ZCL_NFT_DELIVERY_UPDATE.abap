CLASS zcl_nft_delivery_update DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
     types : BEGIN OF ty_delivery_document_in,
                deliverydocument type znft_e_vbeln,
             end of ty_delivery_document_in.
    class-METHODS save_document_prepare IMPORTING iv_delivery_document_in type ty_delivery_document_in.