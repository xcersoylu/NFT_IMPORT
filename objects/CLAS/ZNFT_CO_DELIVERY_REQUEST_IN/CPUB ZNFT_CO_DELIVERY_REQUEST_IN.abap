class ZNFT_CO_DELIVERY_REQUEST_IN definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods DELIVERY_REQUEST_IN
    importing
      !INPUT type ZNFT_DELIVERY_REQUEST
    raising
      CX_AI_SYSTEM_FAULT .