CLASS lcl_slt_ub_triggers_ud DEFINITION.
  PUBLIC SECTION.
    TYPES : ty_operation TYPE c LENGTH 1.
    CONSTANTS :
      BEGIN OF c_operation,
        download TYPE ty_operation VALUE 'D',
        upload   TYPE ty_operation VALUE 'U',
      END OF c_operation.
    CLASS-METHODS : get_instance IMPORTING mt_id           TYPE dmc_acspl_select-mt_id
                                           download        TYPE lcl_slt_ub_triggers_ud=>ty_operation
                                           upload          TYPE lcl_slt_ub_triggers_ud=>ty_operation
                                           path            TYPE rlgrap-filename
                                 RETURNING VALUE(instance) TYPE REF TO lcl_slt_ub_triggers_ud.
    METHODS :
      constructor IMPORTING mt_id     TYPE dmc_acspl_select-mt_id
                            operation TYPE lcl_slt_ub_triggers_ud=>ty_operation
                            path      TYPE rlgrap-filename,
      run.
  PRIVATE SECTION.
    TYPES : ty_method_name TYPE c LENGTH 30.
    CONSTANTS : BEGIN OF c_origin,
                  database   TYPE ty_method_name VALUE 'SELECT',
                  filesystem TYPE ty_method_name VALUE 'UPLOAD',
                END OF c_origin.
    CONSTANTS : BEGIN OF c_destination,
                  database   TYPE ty_method_name VALUE 'INSERT',
                  filesystem TYPE ty_method_name VALUE 'DOWNLOAD',
                END OF c_destination.
    DATA : _mt_id     TYPE dmc_acspl_select-mt_id,
           _operation TYPE lcl_slt_ub_triggers_ud=>ty_operation,
           _path      TYPE string.
    METHODS :
      download IMPORTING table TYPE string itab TYPE STANDARD TABLE,
      upload IMPORTING table TYPE string EXPORTING itab TYPE STANDARD TABLE,
      select IMPORTING table TYPE string EXPORTING itab TYPE STANDARD TABLE,
      insert IMPORTING table TYPE string itab TYPE STANDARD TABLE.
ENDCLASS.

CLASS lcl_slt_ub_triggers_ud IMPLEMENTATION.

  METHOD get_instance.
    CREATE OBJECT instance
      EXPORTING
        mt_id     = mt_id
        operation = COND #( WHEN download EQ abap_true THEN c_operation-download ELSE c_operation-upload )
        path      = path.
  ENDMETHOD.

  METHOD constructor.
    me->_mt_id = mt_id.
    me->_operation = operation.
    me->_path = path.
  ENDMETHOD.

  METHOD download.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = me->_path && table && '.TXT'
        write_field_separator = 'X'
      TABLES
        data_tab              = itab.
  ENDMETHOD.

  METHOD upload.
    CLEAR itab[].
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename            = me->_path && table && '.TXT'
        has_field_separator = 'X'
      TABLES
        data_tab            = itab.
  ENDMETHOD.

  METHOD select.
    SELECT * FROM (table) INTO TABLE itab WHERE mt_id = me->_mt_id.
  ENDMETHOD.

  METHOD insert.
    MODIFY (table) FROM TABLE itab.
  ENDMETHOD.

  METHOD run.
    DATA : t_iuuc_perf_option TYPE STANDARD TABLE OF iuuc_perf_option,
           t_dmc_perf_options TYPE STANDARD TABLE OF dmc_perf_options,
           t_dmc_acspl_select TYPE STANDARD TABLE OF dmc_acspl_select,
           t_iuuc_spc_procopt TYPE STANDARD TABLE OF iuuc_spc_procopt.
    DATA(origin) = COND #( WHEN me->_operation = lcl_slt_ub_triggers_ud=>c_operation-download THEN me->c_origin-database ELSE me->c_origin-filesystem ).
    DATA(destination) = COND #( WHEN me->_operation = lcl_slt_ub_triggers_ud=>c_operation-download THEN me->c_destination-filesystem ELSE me->c_destination-database ).
    CALL METHOD me->(origin) EXPORTING table = 'IUUC_PERF_OPTION' IMPORTING itab = t_iuuc_perf_option.
    CALL METHOD me->(origin) EXPORTING table = 'DMC_PERF_OPTIONS' IMPORTING itab = t_dmc_perf_options.
    CALL METHOD me->(origin) EXPORTING table = 'DMC_ACSPL_SELECT' IMPORTING itab = t_dmc_acspl_select.
    CALL METHOD me->(origin) EXPORTING table = 'IUUC_SPC_PROCOPT' IMPORTING itab = t_iuuc_spc_procopt.
    CALL METHOD me->(destination) EXPORTING table = 'IUUC_PERF_OPTION' itab = t_iuuc_perf_option.
    CALL METHOD me->(destination) EXPORTING table = 'DMC_PERF_OPTIONS' itab = t_dmc_perf_options.
    CALL METHOD me->(destination) EXPORTING table = 'DMC_ACSPL_SELECT' itab = t_dmc_acspl_select.
    CALL METHOD me->(destination) EXPORTING table = 'IUUC_SPC_PROCOPT' itab = t_iuuc_spc_procopt.
  ENDMETHOD.

ENDCLASS.