" Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
" SPDX-License-Identifier: Apache-2.0

CLASS zcl_aws1_cwt_scenario DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS getting_started_with_cwt
      IMPORTING
      !iv_alarm_name TYPE /aws1/cwtalarmname
      !iv_metric_name TYPE /aws1/cwtmetricname
      !iv_namespace TYPE /aws1/cwtnamespace
      !iv_comparison_operator TYPE /aws1/cwtcomparisonoperator
      !iv_statistic TYPE /aws1/cwtstatistic
      !iv_threshold TYPE /aws1/rt_double_as_string
      !iv_alarm_description TYPE /aws1/cwtalarmdescription
      !iv_actions_enabled TYPE /aws1/cwtactionsenabled
      !iv_evaluation_periods TYPE /aws1/cwtevaluationperiods
      !it_dimensions TYPE /aws1/cl_cwtdimension=>tt_dimensions
      !iv_unit TYPE /aws1/cwtstandardunit
      !iv_period TYPE /aws1/cwtperiod
      EXPORTING
      !oo_result TYPE REF TO /aws1/cl_cwtdescralarmsoutput .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AWS1_CWT_SCENARIO IMPLEMENTATION.


  METHOD getting_started_with_cwt.


    CONSTANTS cv_pfl TYPE /aws1/rt_profile_id VALUE 'ZCODE_DEMO'.

    DATA(lo_session) = /aws1/cl_rt_session_aws=>create( cv_pfl ).
    DATA(lo_cwt) = /aws1/cl_cwt_factory=>create( lo_session ).

    "This example scenario contains the following actions:"
    " 1. Create an Amazon CloudWatch alarm for the Amazon Simple Storage Service (Amazon S3) bucket "
    " 2. Disable the CloudWatch alarm actions "
    " 3. Describe the CloudWatch alarm "
    " 4. Delete the alarm "

    "snippet-start:[cwt.abapv1.getting_started_with_cwt]

    DATA lt_alarmnames TYPE /aws1/cl_cwtalarmnames_w=>tt_alarmnames.
    DATA lo_alarmname TYPE REF TO /aws1/cl_cwtalarmnames_w.

    "Create an alarm"
    TRY.
        lo_cwt->putmetricalarm(
          iv_alarmname                 = iv_alarm_name
          iv_comparisonoperator        = iv_comparison_operator
          iv_evaluationperiods         = iv_evaluation_periods
          iv_metricname                = iv_metric_name
          iv_namespace                 = iv_namespace
          iv_statistic                 = iv_statistic
          iv_threshold                 = iv_threshold
          iv_actionsenabled            = iv_actions_enabled
          iv_alarmdescription          = iv_alarm_description
          iv_unit                      = iv_unit
          iv_period                    = iv_period
          it_dimensions                = it_dimensions ).
        MESSAGE 'Alarm created' TYPE 'I'.
      CATCH /aws1/cx_cwtlimitexceededfault.
        MESSAGE 'The request processing has exceeded the limit' TYPE 'E'.
    ENDTRY.

    "Create an ABAP internal table for the created alarm."
    lo_alarmname = NEW #( iv_value = iv_alarm_name ).
    INSERT lo_alarmname INTO TABLE lt_alarmnames.

    "Disable alarm actions."
    TRY.
        lo_cwt->disablealarmactions(
          it_alarmnames                = lt_alarmnames ).
        MESSAGE 'Alarm actions disabled' TYPE 'I'.
      CATCH /aws1/cx_rt_service_generic INTO DATA(lo_disablealarm_exception).
        DATA(lv_disablealarm_error) = |"{ lo_disablealarm_exception->av_err_code }" - { lo_disablealarm_exception->av_err_msg }|.
        MESSAGE lv_disablealarm_error TYPE 'E'.
    ENDTRY.

    "Describe alarm using the same ABAP internal table."
    TRY.
        oo_result = lo_cwt->describealarms(                       " oo_result is returned for testing purpose "
          it_alarmnames                = lt_alarmnames ).
        MESSAGE 'Alarms retrieved' TYPE 'I'.
      CATCH /aws1/cx_rt_service_generic INTO DATA(lo_describealarms_exception).
        DATA(lv_describealarms_error) = |"{ lo_describealarms_exception->av_err_code }" - { lo_describealarms_exception->av_err_msg }|.
        MESSAGE lv_describealarms_error TYPE 'E'.
    ENDTRY.

    "Delete alarm."
    TRY.
        lo_cwt->deletealarms(
          it_alarmnames = lt_alarmnames ).
        MESSAGE 'Alarms deleted' TYPE 'I'.
      CATCH /aws1/cx_cwtresourcenotfound.
        MESSAGE 'Resource being access is not found.' TYPE 'E'.
    ENDTRY.
    "snippet-end:[cwt.abapv1.getting_started_with_cwt]

  ENDMETHOD.
ENDCLASS.
