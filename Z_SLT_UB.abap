REPORT z_slt_ub.

INCLUDE z_slt_ub_triggers_ud.

PARAMETERS : mt_id    TYPE dmc_acspl_select-mt_id DEFAULT '007',
             download TYPE lcl_slt_ub_triggers_ud=>ty_operation RADIOBUTTON GROUP op DEFAULT 'X',
             upload   TYPE lcl_slt_ub_triggers_ud=>ty_operation RADIOBUTTON GROUP op,
             path     TYPE rlgrap-filename DEFAULT 'C:\TEMP\'.

START-OF-SELECTION.
  DATA(o_report) = lcl_slt_ub_triggers_ud=>get_instance( mt_id = mt_id
                                             download = download
                                             upload = upload
                                             path = path ).
  o_report->run( ).