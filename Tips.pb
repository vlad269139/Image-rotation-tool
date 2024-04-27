

Procedure WindowFromHWND(hWnd)
  ProcedureReturn GetProp_(hWnd,"PB_windowID")-1
EndProcedure
Procedure GadgetFromHWND(hWnd)
  ProcedureReturn GetProp_(hWnd,"PB_ID")
EndProcedure

Procedure GetParentWindow(GadgetID)
  ProcedureReturn (GetProp_(GetParent_(GadgetID),"PB_windowID")-1)
EndProcedure

Procedure GetParentGadget(GadgetID)
  ProcedureReturn (GetProp_(GetParent_(GadgetID),"PB_ID"))
EndProcedure

Procedure GetContainerWidth(Gadget)
  GadgetID = GadgetID(Gadget)
  R = GetParentWindow(GadgetID)
  If R=-1
    R = GetParentGadget(GadgetID)
    ProcedureReturn GadgetWidth(R)
  Else
    ProcedureReturn WindowWidth(R)
  EndIf
EndProcedure

Macro Div_Width(Width,Cols,Margin=5,ColSpan = 1)
  (((Width+Margin)/Cols)*ColSpan-Margin)
EndMacro

Macro Div_Height(Height,Rows,Margin=5,RowSpan = 1)
  (((Height+Margin)/Rows)*RowSpan-Margin)
EndMacro

Procedure NextGadgetX(PrevGadget, Margin = 5)
  ProcedureReturn  GadgetX(PrevGadget)+GadgetWidth(PrevGadget)+Margin
EndProcedure

Procedure NextGadgetY(PrevGadget, Margin = 5)
  ProcedureReturn  GadgetY(PrevGadget)+GadgetHeight(PrevGadget)+Margin
EndProcedure
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 14
; Folding = --
; EnableXP