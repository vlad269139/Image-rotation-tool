;- START

Structure LISTd
  List D.d()
EndStructure

Structure PARAMGRAPH Extends LISTd
  Color.l
  Min.d
  Max.d
EndStructure

Structure DRAW
  List *Graphs.PARAMGRAPH()
EndStructure

Procedure PARAMGRAPH(Color.l = 0, Min.d = 0, Max.d = 0, *Draw.DRAW = 0)
  *m.PARAMGRAPH = AllocateMemory(SizeOf(PARAMGRAPH))
  InitializeStructure(*M, PARAMGRAPH)
  With *M
    \Color = Color
    \Min = Min
    \Max = max
  EndWith
  If *draw  
    PokeI(AddElement(*Draw\Graphs()), *m)
  EndIf
  ProcedureReturn *m
EndProcedure

Procedure freePARAMGRAPH(*graph.PARAMGRAPH)
  FreeList(*graph\D())
  FreeMemory(*graph)
EndProcedure

Procedure DRAW()
  *mem.DRAW = AllocateMemory(SizeOf(DRAW))
  InitializeStructure(*mem, DRAW)
  ProcedureReturn *mem
EndProcedure

Procedure freeDRAW(*Draw.DRAW)
  ForEach *Draw\Graphs()
    freePARAMGRAPH(*Draw\Graphs())
  Next
  FreeList(*Draw\Graphs())
  FreeMemory(*Draw)
EndProcedure


Procedure.d Translate(InVal.d, InMin.d, InMax.d, OutMin.d, OutMax.d)
  tmp.d = (InVal - InMin)/(InMax - InMin)
  ProcedureReturn OutMin * (1-tmp) + tmp * OutMax
EndProcedure

;-

Procedure DrawPARAMGRAPH(*Graph.PARAMGRAPH, NoteXOffset.d, W.q, H.q, drawText)
  With *Graph
    If ListSize(\D()) = 0
      ProcedureReturn 
    EndIf
;     W.l = VectorOutputWidth()
;     H.l = VectorOutputHeight()
    ColWidth.d = W / ListSize(\D())
;     ColOffset = ColWidth / 2
    
    VectorSourceColor(\Color | $FF000000)
    
    If drawText
    MovePathCursor(NoteXOffset, 0)
    DrawVectorText(Str(\Max))
  EndIf
    
    MovePathCursor(NoteXOffset, H - VectorTextHeight(Str(\Min)))
    DrawVectorText(Str(\Min))
    
    FirstElement(\D())
    
    H = H-10
    
    MovePathCursor(ColWidth / 2, Translate(\D(), \Min, \Max, H, 5))
    
;     Debug "=============================="
;     Debug "DrawPARAMGRAPH"
;     Debug "Sizes "+ W+"x"+H
;     Debug "ColW "+ ColWidth
;     Debug "Color = "+Hex(\Color)
    
    
    ForEach \D()
      AddPathLine((0.5 + ListIndex(\D())) * ColWidth, Translate(\D(), \Min, \Max, H, 5))
;       Debug ">" + ListIndex(\D())+" / "+ListSize(\D())+
;             " > "+\D()+
;             " > "+StrD(PathCursorX(), 1)+"x"+StrD(PathCursorY(), 1)
    Next
    StrokePath(1)
  EndWith
EndProcedure

Procedure DrawDRAW(*Draw.DRAW, W.q, H.q, background = #White, drawLegend = #True)
  Image = CreateImage(#PB_Any, W, H, 24, background)
  If Image
    If StartVectorDrawing(ImageVectorOutput(Image))
      NoteXOffset.d = 5
      F = LoadFont(#PB_Any, "", 10)
      VectorFont(FontID(F))
      ForEach *Draw\Graphs()
        DrawPARAMGRAPH(*Draw\Graphs(), NoteXOffset, W, H, drawLegend)
        txtWmax = VectorTextWidth(StrD(*draw\Graphs()\Max))
        txtWmin = VectorTextWidth(StrD(*draw\Graphs()\Min))
        txtW = txtWmax
        If txtWmin > txtW
          txtW = txtWmin
          EndIf
        NoteXOffset + 10 + txtW
      Next
      StopVectorDrawing()
      FreeFont(F)
    EndIf
  EndIf
  ProcedureReturn Image
EndProcedure

;-

CompilerIf #PB_Compiler_IsMainFile
  *D.DRAW = DRAW()
  
  ; 1, Red
  *G.PARAMGRAPH = PARAMGRAPH(#Red, 0, 255, *D)
  For i = 1 To 10
    PokeD(AddElement(*G\D()), Random(255))
  Next
  
  ;2, Green
  *G.PARAMGRAPH = PARAMGRAPH(#Green, 0, 255, *D)
  For i = 1 To 18
    PokeD(AddElement(*G\D()), Random(255))
  Next
  
  ;3, Blue
  *G.PARAMGRAPH = PARAMGRAPH(#Blue, 0, 255, *D)
  For i = 1 To 18
    PokeD(AddElement(*G\D()), i/18*255)
  Next
  
  I = DrawDRAW(*D, 500, 200)
  SetClipboardImage(I)
  
CompilerEndIf
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 100
; FirstLine = 90
; Folding = --
; EnableXP