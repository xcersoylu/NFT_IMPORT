  METHOD get_instance.
    IF mo_instance IS BOUND.
      ro_instance = mo_instance.
    ELSE.
      mo_instance = ro_instance = NEW #(  ).
    ENDIF.
  ENDMETHOD.