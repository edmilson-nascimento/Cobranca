*&---------------------------------------------------------------------*
*& Report ZFIR0003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zfir0003.

*class lcl_boleto_class definition create public .
*
*  public section.
*
*    types:
*      begin of ty_bkpf,
*        bukrs type bukrs,
*        belnr type belnr_d,
*        gjahr type gjahr,
*        blart type blart,
*        bldat type bldat,
*        xblnr type xblnr1,
*        waers type waers,
*      end of ty_bkpf,
*
*      begin of ty_bseg,
*        bukrs type bukrs,
*        belnr type belnr_d,
*        gjahr type gjahr,
*        buzei type buzei,
*        koart type koart,
*        umskz type umskz,
*        dmbtr type dmbtr,
*        wrbtr type wrbtr,
*        fdtag type bseg-fdtag, "data vencimento
*        kunnr type kunnr,
*        zfbdt type dzfbdt,
*        zterm type dzterm,
*        zbd1t type dzbd1t,
*        zbd2t type dzbd2t,
*        zbd3t type dzbd3t,
*        zlsch type schzw_bseg,
*        hbkid type hbkid,
*        werks type bseg-werks,
*        xref3 type bseg-xref3, "Numero sequencial
*        bupla type bseg-bupla,
*      end of ty_bseg,
*
*
*      bkpf_tab type table of ty_bkpf,
*      bseg_tab type table of ty_bseg.
*
*    constants:
*      c_conta_cliente      type koart value 'D',
*      c_pgto_boleto        type schzw_bseg value 'D',
*      c_operac_n_relevante type vorgn_012a value ' '.
*
*
*    methods get_data
*      importing
*        !belnr       type bkpf-belnr
*        !bukrs       type bukrs
*        !gjahr       type gjahr
*      exporting
*        !regud       type regud
*        !reguh       type reguh
*        !regup       type regup
*        !t001        type t001
*        !address     type bapicustomer_04
*        !detail      type bapicustomer_kna1
*        !codbarras   type char44
*        !linhadig    type dtachr54
*        !nossonumero type char19
*        !empresa     type sadr
*        !tdline      type tttext
*      changing
*        !bal_log     type ref to zcl_bal_log  .
*
*    methods print
*      importing
*        !tddest      type ssfcompop-tddest
*        !regud       type regud
*        !reguh       type reguh
*        !regup       type regup
*        !t001        type t001
*        !address     type bapicustomer_04
*        !detail      type bapicustomer_kna1
*        !codbarras   type char44
*        !linhadig    type dtachr54
*        !nossonumero type char19
*        !juros       type wrbtr default 0
*        !carteira    type char21 default '112'
*        !empresa     type sadr
*        !tdline      type tttext
*      changing
*        !bal_log     type ref to zcl_bal_log  .
*
*    methods update
*      importing
*        !nossonumero type char19
*      changing
*        !bal_log     type ref to zcl_bal_log  .
*
*  protected section.
*
*  private section.
*
*    data:
*      bkpf  type lcl_boleto_class=>ty_bkpf,
*      bseg  type lcl_boleto_class=>ty_bseg,
*      smart type zfit0003,
*      dados type zfis0005.
*
*    methods get_documento
*      importing
*        !belnr   type belnr_d
*        !bukrs   type bukrs
*        !gjahr   type gjahr
*      changing
*        !bal_log type ref to zcl_bal_log  .
*
*    methods get_barcode
*      changing
*        !bal_log type ref to zcl_bal_log  .
*
*    methods get_detalhes
*      changing
*        !bal_log type ref to zcl_bal_log  .
*
*    methods get_estruturas
*      changing
*        !branch  type t001w-j_1bbranch
*        !empresa type sadr
*        !address type bapicustomer_04
*        !detail  type bapicustomer_kna1
*        !regud   type regud
*        !reguh   type reguh
*        !regup   type regup
*        !t001    type t001 .
*
*    methods get_textos
*      importing
*        !banco  type char3 default '341'
*      changing
*        !tdline type tttext .
*
*
*endclass.
*
*class lcl_boleto_class implementation.
*
*
*  method get_data .
*
*    data:
*      branch  type t001w-j_1bbranch .
*
*    me->get_documento(
*      exporting
*        belnr  = belnr
*        bukrs  = bukrs
*        gjahr  = gjahr
*      changing
*        bal_log = bal_log
*    ).
*
*    me->get_detalhes(
*      changing
*        bal_log = bal_log
*    ).
*
*    me->get_barcode(
*      changing
*        bal_log = bal_log
*    ).
*
*    me->get_estruturas(
*      changing
*        branch  = branch
*        empresa = empresa
*        address = address
*        detail  = detail
*        regud   = regud
*        reguh   = reguh
*        regup   = regup
*        t001    = t001
*    ).
*
*    me->get_textos(
*      exporting
*        banco  = '341'
*      changing
*        tdline = tdline
*    ).
*
*  endmethod .
*
*
*  method get_barcode.
*
*    data:
*      banco       type numc3,
*      ausft       type regud-ausft,
*      codbarras   type char44,
*      linhadig    type dtachr54,
*      nossonumero type char19,
*      total       type char10,
*      dtvct       type numc4.
*
*    dados-dmbtr = bseg-dmbtr.
*
*    if bseg-xref3 is initial.
*
*      select single object, subobject, nrrangenr, toyear
*        from nriv
*        into @data(number)
*       where object    eq @smart-object
*         and subobject eq @space
*         and nrrangenr eq '01'
*         and toyear    eq @space .
*
*      if sy-subrc eq 0 .
*      else .
*
*        data(msg) =
*          value bal_s_msg(
*            msgid = 'ZFI'
*            msgno = 000
*            msgty = 'E'
*            msgv1 = 'Objeto de numeração não encontrado'
*            msgv2 = 'para Chave de Banco'
*            msgv3 = 'na tabela ZFIT0003'
*           ) .
*
*        bal_log->add( msg = msg ) .
*
*        exit .
*
*      endif .
*
*      call function 'NUMBER_GET_NEXT'
*        exporting
*          nr_range_nr             = number-nrrangenr
*          object                  = number-object
**         quantity                = '1'    " Number of numbers
**         subobject               = SPACE    " Value of subobject
**         toyear                  = '0000'    " Value of To-fiscal year
**         ignore_buffer           = SPACE    " Ignore object buffering
*        importing
*          number                  = dados-checl
**         quantity                =     " Number of numbers
**         returncode              =     " Return code
*        exceptions
*          interval_not_found      = 1
*          number_range_not_intern = 2
*          object_not_found        = 3
*          quantity_is_0           = 4
*          quantity_is_not_1       = 5
*          interval_overflow       = 6
*          buffer_overflow         = 7
*          others                  = 8.
*
*      if sy-subrc eq 0.
*        shift dados-checl left deleting leading '0'.
*      else .
*      endif.
*
*    else.
*
**      if bseg-belnr ne v_belnr.
**
**        call function 'TR_POPUP_TO_CONFIRM'
**          exporting
**            iv_titlebar      = 'Deseja reimprimir doc. abaixo:'
**            iv_text_question = v_awkey(10)
**            iv_text_button1  = 'Sim'(d01)
**            iv_text_button2  = 'Não'(d02)
**            iv_start_column  = 10
**            iv_start_row     = 6
**          importing
**            ev_answer        = ev_answer.
**        if ev_answer = '2' or
**           ev_answer = 'A'.
**          exit.
**        endif.
**      endif.
*
*
*      dados-checl(13) = bseg-xref3(13) .
*
*    endif.
*
*    ausft = bseg-zfbdt + bseg-zbd1t + bseg-zbd2t + bseg-zbd3t.
*    banco = dados-bankl(3) .
*
*    call function 'ZFFI0002'
*      exporting
*        i_dtvct       = ausft
*        i_banco       = banco
*        i_cta_dados   = dados
*        i_buzei       = bseg-buzei
*      importing
*        e_codbarras   = codbarras
*        e_linhadig    = linhadig
*        e_nossonumero = nossonumero
*        e_cta_dados   = dados
*        e_total       = total
*        e_dtvct       = dtvct.
*
*  endmethod.
*
*
*  method get_documento.
*
*    clear:
*      bkpf.
*
*    select single bukrs belnr gjahr blart bldat xblnr waers
*      from bkpf
*      into bkpf
*     where bukrs eq bukrs
*       and belnr eq belnr
*       and gjahr eq gjahr .
*
*    if sy-subrc eq 0 .
*
*    else .
*
*      data(msg) =
*        value bal_s_msg(
*          msgid = 'ZFI'
*          msgno = 000
*          msgty = 'E'
*          msgv1 = 'Dados não encontrados(BKPF).'
*         ) .
*
*      bal_log->add( msg = msg ) .
*
*    endif.
*
*  endmethod.
*
*  method get_detalhes.
*
*    types:
*      begin of ty_knb1,
*        kunnr type knb1-kunnr,
*        bukrs type knb1-bukrs,
*        hbkid type knb1-hbkid,
*      end of ty_knb1.
*
*    data:
*      bseg_tab   type bseg_tab,
*      knb1_line  type ty_knb1,
*      t012a_line type t012a.
*
*    select bukrs belnr gjahr buzei koart umskz dmbtr wrbtr fdtag kunnr
*           zfbdt zterm zbd1t zbd2t zbd3t zlsch hbkid werks xref3 bupla
*      into table bseg_tab
*      from bseg
*      where bukrs eq bkpf-bukrs
*        and belnr eq bkpf-belnr
*        and gjahr eq bkpf-gjahr .
*
*    if sy-subrc eq 0.
*
*      delete bseg_tab where zterm eq ' '.
*      delete bseg_tab where koart ne c_conta_cliente .
*      delete bseg_tab where zlsch ne c_pgto_boleto .
*
*    endif.
*
*
*    if bseg_tab[] is initial.
*
*      data(msg) =
*        value bal_s_msg(
*          msgid = 'ZFI'
*          msgno = 000
*          msgty = 'E'
*          msgv1 = 'Dados não encontrados(BKPF).'
*         ) .
*
*      bal_log->add( msg = msg ) .
*
*      exit .
*
*    else .
*
*      read table bseg_tab into bseg index 1 .
*
*    endif.
*
*    if bseg-hbkid is initial.
*
*      select single kunnr bukrs hbkid
*        from knb1
*        into knb1_line
*       where kunnr eq bseg-kunnr
*         and bukrs eq bkpf-bukrs .
*
*      exit .
*
*    else.
*      knb1_line-hbkid = bseg-hbkid.
*    endif.
*
**   Seleciona smartforms
*    select single *
*      into smart
*      from zfit0003
*     where hbkid eq knb1_line-hbkid.
*
*    if sy-subrc eq 0.
*
*    else .
*
*      msg =
*      value #(
*        msgid = 'ZFI'
*        msgno = 000
*        msgty = 'E'
*        msgv1 = 'Informação de SmartForms'
*        msgv2 = 'não encontrada na tabela ZFIT0003'
*        msgv3 = 'para Chave de Banco'
*        msgv4 = knb1_line-hbkid
*       ) .
*
*      bal_log->add( msg = msg ) .
*
*      exit .
*
*    endif.
*
**   Seleciona dados do banco/conta/boleto
*    select single *
*      into t012a_line
*      from t012a
*      where bukrs eq bkpf-bukrs
*        and zlsch eq c_pgto_boleto
*        and vorgn eq c_operac_n_relevante
*        and hbkid eq knb1_line-hbkid
*        and wbgru eq ' '
*        and gleor eq ' ' .
*
*    if sy-subrc eq 0 .
*
*      dados-vorga = t012a_line-vorga+1(4).
*
*    else .
*      exit .
*    endif.
*
*    select single hktid bankn bkont bnkn2
*      into (dados-hktid, dados-bankn, dados-bkont, dados-bnkn2 )
*      from t012k
*      where bukrs eq bkpf-bukrs
*        and hbkid eq knb1_line-hbkid .
*
*    if sy-subrc eq 0 .
***      if v_hktid is initial.
***        v_hktid = w_dados-hktid.
***      endif.
*    else.
**     message s000(>0) with text-004 v_hbkid display like 'E'.
*      exit .
*    endif.
*
*    select single dtaid
*      into dados-dtaid
*      from t045t
*     where bukrs eq bkpf-bukrs
*       and zlsch eq c_pgto_boleto
*       and vorga eq c_operac_n_relevante
*       and hbkid eq knb1_line-hbkid.
*
*    if sy-subrc eq 0 .
*    else .
*      exit .
*    endif.
*
*    select single bankl
*      into dados-bankl
*      from t012
*     where bukrs eq bkpf-bukrs
*       and hbkid eq knb1_line-hbkid .
*
*    if sy-subrc eq 0 .
*    else .
*      exit .
*    endif.
*
*  endmethod.
*
*
*  method get_estruturas.
*
*    data:
*      cnpj        type j_1bwfield-cgc_number,
*      stcd1       type char18,
*      return      type bapiret1,
*      it_bseg_ref type table of bseg,
*      it_bkpf_ref type table of bkpf.
*
*    select single *
*      from t001
*      into t001
*     where bukrs eq bseg-bukrs .
*    if sy-subrc eq 0 .
*
*    endif .
*
*    select single bukrs, party, paval
*      into @data(t001z)
*      from t001z
*     where bukrs eq @bseg-bukrs
*       and party eq 'J_1BBR'.
*
*    if sy-subrc eq 0.
*      branch = t001z-paval(4) .
*    endif.
*
*    call function 'J_1BREAD_BRANCH_DATA'
*      exporting
*        branch            = branch
*        bukrs             = bseg-bukrs
*      importing
*        address           = empresa
**       branch_data       =
*        cgc_number        = cnpj
**       address1          =
*      exceptions
*        branch_not_found  = 1
*        address_not_found = 2
*        company_not_found = 3
*        others            = 4.
*
*    if sy-subrc eq 0.
*    else .
*    endif.
*
*    call function 'BAPI_CUSTOMER_GETDETAIL2'
*      exporting
*        customerno            = bseg-kunnr
**       companycode           =
*      importing
*        customeraddress       = address
*        customergeneraldetail = detail
**       customercompanydetail =
*        return                = return.
**     tables
**       customerbankdetail    =
**       customeribandetail    =
**       customersepadetail    =
*    .
*
*    regud-ausft = bseg-zfbdt + bseg-zbd1t + bseg-zbd2t + bseg-zbd3t .
*    regud-wrbtr = bseg-wrbtr .
*    regud-dmbtr = bseg-dmbtr .
**   dias = regud-ausft - sy-datum .
**   reguh-text  = l_stcd1(18).
*
**   CNPJ Cedente
*    call function 'CONVERSION_EXIT_CGCBR_OUTPUT'
*      exporting
*        input  = cnpj
*      importing
*        output = regud-abstx.
*
*    if detail-tax_no_1 is not initial.
*
*      call function 'CONVERSION_EXIT_CGCBR_OUTPUT'
*        exporting
*          input  = detail-tax_no_1
*        importing
*          output = stcd1.
*
*      reguh-text = stcd1(18) .
*
*    elseif detail-tax_no_2 is not initial.
*
*      call function 'CONVERSION_EXIT_CPFBR_OUTPUT'
*        exporting
*          input  = detail-tax_no_2
*        importing
*          output = stcd1.
*
*      reguh-text = stcd1(14).
*
*    endif.
*
*    reguh-zbnkn = dados-zbnkn .
**   carteira    = dados-vorga .
**   if v_carteira = '122'.
**     v_carteira = 'Cobrança Simples RCR'.
**   endif.
*
**   Dados w_regup
*    regup-belnr = bseg-belnr .
*    regup-gjahr = bseg-gjahr .
*    regup-buzei = bseg-buzei .
*    regup-xblnr = bkpf-xblnr .
*    regup-bldat = bkpf-bldat .
*    regup-umskz = bseg-umskz .
*
*
**    select * from bseg into table it_bseg_ref
**      where bukrs = p_bukrs
**        and belnr > '0'
**        and gjahr = p_gjahr
**        and augbl = w_bseg-belnr                     " Valmir 20/12/2016
**        and kunnr = w_bseg-kunnr.                    " Valmir 21/12/2016
**
**    if sy-subrc is initial.
**
**      select * from bkpf into table it_bkpf_ref
**      for all entries in it_bseg_ref
**      where bukrs = it_bseg_ref-bukrs
**        and belnr = it_bseg_ref-belnr
**        and gjahr = it_bseg_ref-gjahr
**        and xblnr <> ''.
**
**      loop at it_bkpf_ref.
**        if v_xblnr is initial .
**          concatenate 'NF(s)' it_bkpf_ref-xblnr into v_xblnr separated by '-'.
**        else.
**          concatenate v_xblnr it_bkpf_ref-xblnr into v_xblnr separated by '/'.
**        endif.
**      endloop.
**    endif.
*
*    translate t001-butxt  to upper case.
*    translate regud-abstx to upper case.
*
*  endmethod.
*
*
*  method get_textos.
*
*    data:
*     name  type tdobname .
*
*    refresh:
*      tdline.
*
*    name = banco .
*
*    call function 'READ_TEXT'
*      exporting
*        client                  = sy-mandt
*        id                      = 'ST'
*        language                = sy-langu
*        name                    = name
*        object                  = 'TEXT'
*      tables
*        lines                   = tdline
*      exceptions
*        id                      = 1
*        language                = 2
*        name                    = 3
*        not_found               = 4
*        object                  = 5
*        reference_check         = 6
*        wrong_access_to_archive = 7
*        others                  = 8.
*
*    if sy-subrc eq 0 .
*
*    endif.
*
*  endmethod.
*
*
*  method print .
*
*    data:
*      fm_name              type rs38l_fnam,
*
*      control_parameters   type ssfctrlop,
*      output_options       type ssfcompop,
*      document_output_info type ssfcrespd,
*      job_output_info      type ssfcrescl,
*      job_output_options   type ssfcresop,
*
*      msg                  type bal_s_msg.
*
*    call function 'SSF_FUNCTION_MODULE_NAME'
*      exporting
*        formname           = smart-fname
**       variant            = space
**       direct_call        = space
*      importing
*        fm_name            = fm_name
*      exceptions
*        no_form            = 1
*        no_function_module = 2
*        others             = 3.
*
*    if sy-subrc eq 0.
*
*      if tddest is not initial.
*        output_options-tddest = tddest .
*      else.
*        output_options-tddest = 'LOCL'.
*      endif.
*
*      control_parameters-no_dialog = abap_on .
*
*      output_options-tdnoprev      = abap_on .
*      output_options-tdimmed       = abap_off .
*      output_options-tdnewid       = abap_on .
*
*      call function fm_name
*        exporting
*          control_parameters   = control_parameters
*          output_options       = output_options
*          user_settings        = space
*          regud                = regud
*          regup                = regup
*          t001                 = t001
*          reguh                = reguh
*          w_address            = address
*          w_detail             = detail
*          v_barcode            = codbarras
*          v_linha              = linhadig
*          v_nosso_num          = nossonumero
*          v_juros              = juros
*          v_carteira           = carteira
*          v_xblnr              = ''
*          w_empresa            = empresa
*        importing
*          document_output_info = document_output_info
*          job_output_info      = job_output_info
*          job_output_options   = job_output_options
*        tables
*          t_line               = tdline
*        exceptions
*          formatting_error     = 1
*          internal_error       = 2
*          send_error           = 3
*          user_canceled        = 4
*          others               = 5.
*
*      if sy-subrc ne 0.
*
*        bal_log->syst_to_ballog(
*          exporting
*            syst      = sy
*          importing
*            bal_s_msg = msg
*        ).
*
*        bal_log->add( msg = msg ) .
*
*      endif.
*
*    else.
*
*      msg =
*        value #(
*          msgid = 'ZFI'
*          msgno = 000
*          msgty = 'E'
*          msgv1 = 'Módulo de função não encontrado.'
*          msgv2 = 'Favor verificar SmartForms em '
*          msgv3 = 'Tabela ZFIT0003.'
*         ) .
*
*      bal_log->add( msg = msg ) .
*
*    endif.
*
*  endmethod.
*
*  method update.
*
*    data:
*      partida  type string,
*      dismode  type ctu_mode,
*      updmode  type ctu_update,
*      messages type tab_bdcmsgcoll,
*      bal_msg  type bal_s_msg.
*
*    concatenate 'RF05L-ANZDT(' bseg-buzei+1(2) ')' into partida .
*
*    data(bdcdata) = value bdcdata_tab(
*      ( program  = 'SAPMF05L'        dynpro = '0100' dynbegin = 'X' )
*          ( fnam = 'BDC_OKCODE'      fval   = '/00' )
*          ( fnam = 'RF05L-BELNR'     fval   = bseg-belnr )
*          ( fnam = 'RF05L-BUKRS'     fval   = bseg-bukrs )
*          ( fnam = 'RF05L-GJAHR'     fval   = bseg-gjahr )
*
*      ( program  = 'SAPMF05L'        dynpro = '0700' dynbegin = 'X' )
*          ( fnam = 'BDC_OKCODE'      fval   = '=PK' )
*          ( fnam = 'BDC_CURSOR'      fval   = partida )
*
*      ( program  = 'SAPMF05L'        dynpro = '0301' dynbegin = 'X' )
*          ( fnam = 'BDC_OKCODE'      fval   = '=NZ' )
*
*
*      ( program  = 'SAPMF05L'        dynpro = '1160' dynbegin = 'X' )
*          ( fnam = 'BDC_OKCODE'      fval   = '=ENTR' )
*          ( fnam = 'RF05L-BUZEI'     fval   = bseg-buzei+1(2) )
*
*      ( program  = 'SAPMF05L'        dynpro = '0301' dynbegin = 'X' )
*          ( fnam = 'BDC_OKCODE'      fval   = '=ZK' )
*
*      ( program  = 'SAPMF05L'        dynpro = '1301' dynbegin = 'X' )
*          ( fnam = 'BDC_OKCODE'      fval   = '=ENTR' )
*          ( fnam = 'BSEG-XREF3'      fval   = nossonumero )
*          ( fnam = 'BSEG-HBKID'      fval   = bseg-hbkid )
*          ( fnam = 'BSEG-HKTID'      fval   = dados-hktid )
*
*      ( program  = 'SAPMF05L'        dynpro = '0301' dynbegin = 'X' )
*          ( fnam = 'BDC_OKCODE'      fval   = '=AE' ) ) .
*
*    "A" Processing with display of screens
*    "E" Display of screens only if an error occurs
*    "N" Processing without display of screens. If a breakpoint is reached in one
*    "P" Processing without display of the screens. If a breakpoint is reached in
*
*    dismode = 'E' .
*
*    "L Local
*    "S Síncrono
*    "A Assíncrono
*
*    updmode = 'S' .
*
*    data(params) = value ctu_params( dismode = dismode
*                                     updmode = updmode
*                                     defsize = 'X' ) .
*
*    call transaction 'FB02' using bdcdata
*                            options from params
*                            messages into messages .
*
**     Verificando se deve fechar a janela de manutenção
*    read table messages into data(message)
*      with key msgtyp = 'S'
*               msgid  = 'F5'
*               msgnr  = '312' .
*    if sy-subrc eq 0 .
*
*      bal_log->bdcmsgcoll_to_ballog(
*        exporting
*          bdcmsgcoll = message
*        importing
*          bal_s_msg  = bal_msg
*      ).
*
*      bal_log->add( msg = bal_msg ).
*
*    endif .
*
*
*  endmethod.
*
*endclass.


type-pools:
  abap .

**********************************************************************
*-
**********************************************************************
data:
* boleto      type ref to lcl_boleto_class,
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