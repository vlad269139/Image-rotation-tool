



DeclareModule UIHelp
  
   ; XIncludeFile "Tips.pb"
  
  #APP_MainWindow = 0
  Enumeration WindowControls
    #APP_Controls_ImageCanvas
    
    #APP_Ctrl_EnumStart
    
    #APP_Controls_OpenImage
    #APP_Controls_ReloadImage
    
    
    
    #APP_Controls_StartSelectionSpin
    #APP_Controls_SelectionSizeSpin
    
    #APP_Controls_ShowSelectionCheck
    
    #APP_Controls_MovementSizeSpin
    #APP_Controls_MoveLeftButton
    #APP_Controls_MoveRightButton
    
    #APP_Controls_AutoSetting
    #APP_Controls_Auto_SelectionOnly
    #APP_Controls_Automatic
    
    #APP_Controls_SaveImage
    
    #APP_Controls_Filter_enable
    #APP_Controls_Filter_size
    
    #APP_Ctrl_EnumEnd
    
    #APP_txt_SelectionStart
    #APP_txt_SelectionSize
    #APP_txt_MovementSize
    #APP_txt_AutoLookup
    #APP_txt_BW_tres
;     #APP_txt_
    
    #APP_Controls_ControlGroup
    
    #APP_Controls_TopGraph
    #APP_Controls_BottomGraph
    
    
    
    #App_Controls_ControlsPanel
    
  EndEnumeration
  
  ;- IUI
  Interface IUI
    SelectionStart_get.l()
    SelectionStart_set(value.l)
    SelectionStartMax_get()
    SelectionStartMax_set(value.l)
    
    SelectionSize_get.l()
    SelectionSize_set(value.l)
    SelectionSizeMax_get()
    SelectionSizeMax_set(value.l)
    
    ShowSelection_get.l()
    ShowSelection_set(value)
    
    
    MovementSize_get.l()
    MovementSize_set(value.l)
    MovementSizeMax_get()
    MovementSizeMax_set(value.l)
    
    
    GetGraphWidth()
    GetGraphHeight()
    
    UpdateView()
    SetViewImage(image)
    
    DisableControls(keepOpenBtn = #True, keepAutoButton = #False)
    EnableControls()
    
    GetAutomaticSetting()
    AutoSelectionOnly_get()
    
    FilterEnabled_get()
    FilterEnabled_set(value.l)
    
    FilterTreshold_get()
    FilterTreshold_set(value.l)
  EndInterface
  
  Global UI.IUI = 0
  Declare PrepareUI()
EndDeclareModule

Module UIHelp
  
  Structure _UI
    *vt
  EndStructure
  
  
  Procedure PrepareUI()
    *mem._UI = AllocateMemory(SizeOf(_UI))
    *mem\vt = ?vt_UI
    UI = *mem
  EndProcedure
  
  
  
  
  ;-
  ;- #APP_Controls_StartSelectionSpin
  Procedure.l SelectionStart_get(*this._UI)
    ProcedureReturn GetGadgetState(#APP_Controls_StartSelectionSpin)
  EndProcedure
  Procedure SelectionStart_set(*this._UI, value.l)
    SetGadgetState(#APP_Controls_StartSelectionSpin, value)
    SetGadgetText(#APP_Controls_StartSelectionSpin, Str(value))
  EndProcedure
  Procedure SelectionStartMax_set(*this._UI, value.l)
    SetGadgetAttribute(#APP_Controls_StartSelectionSpin, #PB_Spin_Maximum, value)
  EndProcedure
  Procedure SelectionStartMax_get(*this._UI)
    ProcedureReturn GetGadgetAttribute(#APP_Controls_StartSelectionSpin, #PB_Spin_Maximum)
    EndProcedure
    
    ;-
  ;- #APP_Controls_SelectionSizeSpin
  Procedure.l SelectionSize_get(*this._UI)
    ProcedureReturn GetGadgetState(#APP_Controls_SelectionSizeSpin)
  EndProcedure
  
  Procedure.l SelectionSize_set(*this._UI, value.l)
    SetGadgetState(#APP_Controls_SelectionSizeSpin, value)  
    SetGadgetText(#APP_Controls_SelectionSizeSpin, Str(value))
  EndProcedure
  
  Procedure SelectionSizeMax_get(*this._UI)
    ProcedureReturn GetGadgetAttribute(#APP_Controls_SelectionSizeSpin, #PB_Spin_Maximum)
  EndProcedure
  Procedure SelectionSizeMax_set(*this._UI, value.l)  
    SetGadgetAttribute(#APP_Controls_SelectionSizeSpin, #PB_Spin_Maximum, value)
  EndProcedure
  
  ;-
  ;- #APP_Controls_ShowSelectionCheck
  Procedure.l ShowSelection_get(*this._UI)
    ProcedureReturn GetGadgetState(#APP_Controls_ShowSelectionCheck)
  EndProcedure
  
  Procedure ShowSelection_set(*this._UI, value)
    SetGadgetState(#APP_Controls_ShowSelectionCheck, value)
  EndProcedure
  
  ;-
  ;- #APP_Controls_MovementSizeSpin
  Procedure.l MovementSize_get(*this._UI)
    ProcedureReturn GetGadgetState(#APP_Controls_MovementSizeSpin)
  EndProcedure
  Procedure.l MovementSize_set(*this._UI, value.l)
    SetGadgetState(#APP_Controls_MovementSizeSpin, value)
    SetGadgetText(#APP_Controls_MovementSizeSpin, Str(value))
  EndProcedure
  Procedure MovementSizeMax_get(*this._UI)
    ProcedureReturn  GetGadgetAttribute(#APP_Controls_MovementSizeSpin, #PB_Spin_Maximum)
  EndProcedure
  Procedure MovementSizeMax_set(*this._UI, value.l)
    SetGadgetAttribute(#APP_Controls_MovementSizeSpin, #PB_Spin_Maximum, value)
  EndProcedure
  
  ;-
  ;- Graphs
  Procedure GetGraphWidth(*this._UI)
    ProcedureReturn GadgetWidth(#APP_Controls_TopGraph)
  EndProcedure
  Procedure GetGraphHeight(*this._UI)
    ProcedureReturn GadgetHeight(#APP_Controls_TopGraph)
  EndProcedure
  
  ;; Views
  Procedure UpdateView(*this._UI)
    CanvasViewer::RedrawCanvasView(#APP_Controls_ImageCanvas)
  EndProcedure
  
  Procedure SetViewImage(*this._UI, image)
    CanvasViewer::SetCanvasImage(#APP_Controls_ImageCanvas, image)
    CanvasViewer::ResetCanvasView(#APP_Controls_ImageCanvas)
  EndProcedure
  
  
  
  
  
  Procedure DisableControls(*this, keepOpenBtn = #True, keepAutoButton = #False)
    
;     Debug "DisableControls()"
    
    For i = #APP_Ctrl_EnumStart + 1 To #APP_Ctrl_EnumEnd - 1
      b = Bool((i = #APP_Controls_OpenImage And keepOpenBtn) Or (i = #APP_Controls_Automatic And keepAutoButton) )
        DisableGadget(i, 1 - b)
      
    Next
  EndProcedure
  Procedure EnableControls()
;     Debug "EnableControls()"
    For i = #APP_Ctrl_EnumStart + 1 To #APP_Ctrl_EnumEnd - 1
      DisableGadget(i, 0)
    Next
  EndProcedure
  
  
  ;-
  ;- #APP_Controls_Auto_SelectionOnly
  Procedure AutoSelectionOnly_get()
    ProcedureReturn GetGadgetState(#APP_Controls_Auto_SelectionOnly)
  EndProcedure
  
  ;- 
  ;- #APP_Controls_AutoSetting
  Procedure GetAutomaticSetting()
    ProcedureReturn GetGadgetState(#APP_Controls_AutoSetting)
  EndProcedure
  
  
  ;-
  ;- #APP_Controls_Filter_enable
  Procedure FilterEnabled_get()
    ProcedureReturn GetGadgetState(#APP_Controls_Filter_enable)
  EndProcedure
  Procedure FilterEnabled_set(*this, value.l)
    ProcedureReturn SetGadgetState(#APP_Controls_Filter_enable, value)
  EndProcedure
  
  
  ;-
  ;- #APP_Controls_Filter_size
  Procedure FilterTreshold_get()
    ProcedureReturn GetGadgetState(#APP_Controls_Filter_size)
  EndProcedure
  Procedure FilterTreshold_set(*this, value.l)
    ProcedureReturn SetGadgetState(#APP_Controls_Filter_size, value)
  EndProcedure
  
  
  
  
  
  DataSection
    vt_UI:
    Data.i @SelectionStart_get(), @SelectionStart_set(), @SelectionStartMax_get(), @SelectionStartMax_set(), 
           @SelectionSize_get(), @SelectionSize_set(), @SelectionSizeMax_get(), @SelectionSizeMax_set(),
           @ShowSelection_get(), @ShowSelection_set(),
           @MovementSize_get(), @MovementSize_set(), @MovementSizeMax_get(), @MovementSizeMax_set(),
           @GetGraphWidth(), @GetGraphWidth(),
           @UpdateView(), @SetViewImage(),
           @DisableControls(), @EnableControls(),
           @GetAutomaticSetting(), @AutoSelectionOnly_get(),
           @FilterEnabled_get(), @FilterEnabled_set(),
           @FilterTreshold_get(), @FilterTreshold_set()

    
    
  EndDataSection
  
EndModule
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 43
; Folding = -----
; EnableXP
; DPIAware