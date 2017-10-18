*&---------------------------------------------------------------------*
*& Report ZFIR0003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zfir0003.


type-pools:
  abap .

**********************************************************************
*-
**********************************************************************
data:
  boleto      type ref to zcl_fi_boleto,
  bal_log     type ref to zcl_bal_log,

  identif     type  balnrext,
  regud       type regud,
  reguh       type reguh,
  regup       type regup,
  t001        type t001,
  address     type bapicustomer_04,
  detail      type bapicustomer_kna1,
  codbarras   type char44,
  linhadig    type dtachr54,
  nossonumero type char19,
  juros       type wrbtr value 0,
  carteira    type char21 value '112',
  empresa     type sadr,
  tdline      type tttext.

*&---------------------------------------------------------------------*
*& Tela de seleção                                                     *
*&---------------------------------------------------------------------*
selection-screen begin of block b1 with frame title text-001.

parameters:
  p_belnr  type bkpf-belnr,
  p_bukrs  type bkpf-bukrs,
  p_gjahr  type bkpf-gjahr,
  p_impres type nast-ldest.

selection-screen end of block b1.

*&---------------------------------------------------------------------*
*& Eventos                                                             *
*&---------------------------------------------------------------------*

initialization.

start-of-selection.

  create object bal_log
    exporting
      identif   = identif
      object    = 'ZFI'
      subobject = 'ZFI0003'
      alprog    = sy-cprog.

  create object boleto .

  boleto->get_data(
    exporting
      belnr       = p_belnr
      bukrs       = p_bukrs
      gjahr       = p_gjahr
    importing
      regud       = regud
      reguh       = reguh
      regup       = regup
      t001        = t001
      address     = address
      detail      = detail
      codbarras   = codbarras
      linhadig    = linhadig
      nossonumero = nossonumero
      empresa     = empresa
      tdline      = tdline
    changing
      bal_log     = bal_log
  ).

  boleto->print(
    exporting
      spool       = abap_off
      tddest      = p_impres
      regud       = regud
      reguh       = reguh
      regup       = regup
      t001        = t001
      address     = address
      detail      = detail
      codbarras   = codbarras
      linhadig    = linhadig
      nossonumero = nossonumero
*     juros       = 0
*     carteira    = '112'
      empresa     = empresa
      tdline      = tdline
    changing
      bal_log     = bal_log
  ).

    boleto->update(
      exporting
        nossonumero = nossonumero
      changing
        bal_log     = bal_log
    ).
