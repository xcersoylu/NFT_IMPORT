  METHOD constructor.
    SELECT *
    FROM znft_t_parameter
    WHERE parametername = 'API'
    INTO CORRESPONDING FIELDS OF TABLE @mt_parameters.
  ENDMETHOD.