UsePNGImageDecoder()
UsePNGImageEncoder()

Structure ABGR
  Red.a
  Green.a
  Blue.a
  Alpha.a
EndStructure

Structure PIXEL
  Id.q
  StructureUnion
    Color.l
    RGB.ABGR
  EndStructureUnion
EndStructure

Structure IMAGEDIMY
  Array Y.PIXEL(0)
EndStructure

Procedure IMAGEDIMY(Height.q)
  *m.IMAGEDIMY = AllocateMemory(SizeOf(IMAGEDIMY))
  InitializeStructure(*m, IMAGEDIMY)
  ReDim *m\Y(Height-1)
  ProcedureReturn *M
EndProcedure

Structure IMAGEDIM
  Array *X.IMAGEDIMY(0)
  Width.q
  Height.q
EndStructure

Procedure IMAGEDIM(Width.q, Height.q)
  *m.IMAGEDIM = AllocateMemory(SizeOf(IMAGEDIM))
  InitializeStructure(*m, IMAGEDIM)
  
  ReDim *m\X(Width-1)
  
  *m\Width = Width
  *m\Height = Height
  
  For X = 0 To Width-1
    *m\X(X) = IMAGEDIMY(Height)
  Next
  ProcedureReturn *M
EndProcedure


Procedure FreeIMAGEDIM(*image.IMAGEDIM)
  For x = 0 To *image\Width - 1
    For y = 0 To *image\Height - 1
      FreeArray(*image\X(x)\Y())
    Next
    FreeMemory(*image\X(x))
  Next
  FreeArray(*image\X())
  FreeMemory(*image)
EndProcedure




Procedure ImageToDim(Image)
  iW.q = ImageWidth(Image)
  iH.q = ImageHeight(Image)
  
  *out.IMAGEDIM = IMAGEDIM(iW, iH)
  
  StartDrawing(ImageOutput(Image))
  DrawingMode(#PB_2DDrawing_AllChannels)
  
  
  
  For Y.q = 0 To iH - 1
    For X.q = 0 To iW - 1
      ;       Debug ""+X+"x"+Y
      *out\X(X)\Y(Y)\Color = Point(X, Y)
      
      ;       PokeL(*out\X(X)\Y(Y), )
    Next
  Next
  
  StopDrawing()
  ProcedureReturn *out
EndProcedure

Procedure IMAGEDIMtoImage(*image.IMAGEDIM)
  I.q = CreateImage(#PB_Any, *image\Width, *image\Height, 32,$FFFFFFFF)
  StartDrawing(ImageOutput(I))
  DrawingMode(#PB_2DDrawing_AllChannels)
  For Y.q = 0 To *image\Height - 1
    For X.q = 0 To *image\Width - 1
      Plot(X, Y, *image\X(X)\Y(Y)\Color)
    Next
  Next
  StopDrawing()
  ProcedureReturn I
EndProcedure

Procedure SaveIMAGEDIM(*image.IMAGEDIM, File$)
  I = IMAGEDIMtoImage(*image)
  SaveImage(I, File$, #PB_ImagePlugin_PNG)
  FreeImage(I)
EndProcedure

Macro Invert(Color)
  color = (255 - color)
EndMacro

#dif = $08

Macro Diff(V1, V2)
  v2 - v1
EndMacro

Macro AbsDiff(V1, V2)
  Abs(Diff(V1, V2))
EndMacro

Macro IsPositive(Val)
  Bool(Val >= 0)
EndMacro

Macro ColorDif(Val, OutColor)
  If Val > 0
    OutColor = $FF
  ElseIf Val < 0
    OutColor = $80
  EndIf
EndMacro

Procedure CheckColorDif(*C1.ABGR, *C2.ABGR, Diff.w = #dif)
  
  cR.w = AbsDiff(*C1\Red, *C2\Red)
  cG.w = AbsDiff(*C1\Green, *C2\Green)
  cB.w = AbsDiff(*C1\Blue, *C2\Blue)
  
  If cR>Diff Or cG>Diff Or cB>Diff
    ProcedureReturn 1
  EndIf
  
EndProcedure

Macro CheckMax(CurrMax, CheckMax)
  If CheckMax > CurrMax
    CurrMax = CheckMax
  EndIf
EndMacro

Procedure.d MixVal(Val1.d, Val2.d, Mix.d)
  ProcedureReturn ((Val1 * (1-Mix)) + Val2 * Mix)
EndProcedure

Procedure.l ColorMix(Color1.l, Color2.l, Mix.d)
  R1.a = Red(Color1)
  G1.a = Green(Color1)
  B1.a = Blue(Color1)
  A1.a = Alpha(Color1)
  
  R2.a = Red(Color2)
  G2.a = Green(Color2)
  B2.a = Blue(Color2)
  A2.a = Alpha(Color2)
  
  ProcedureReturn RGBA(MixVal(R1, R2, Mix), MixVal(G1, G2, Mix), MixVal(B1, B2, Mix), MixVal(A1, A2, Mix))
EndProcedure

Procedure.q AssignID(*image.IMAGEDIM)
  
  MaxID.q = 0
  
  For Y = 0 To *image\Height - 2
    *image\X(0)\Y(Y+1)\Id = *image\X(0)\Y(Y)\Id + 
                            CheckColorDif(@*image\X(0)\Y(Y)\RGB, @*image\X(0)\Y(Y+1)\RGB)
  Next
  
  For Y = 0 To *image\Height - 2
    For X = 0 To *image\Width - 2
      *image\X(X+1)\Y(Y)\Id = *image\X(X)\Y(Y)\Id + 
                              CheckColorDif(@*image\X(X)\Y(Y)\RGB, @*image\X(X+1)\Y(Y)\RGB)
      
      CheckMax(MaxID, *image\X(X+1)\Y(Y)\Id)
    Next
  Next
  
  ;   Debug "  MaxID > "+MaxID
  
  ProcedureReturn MaxID
EndProcedure


CompilerIf #PB_Compiler_IsMainFile
  
  Procedure.l CalcNewColor(*oldImg.IMAGEDIM, NewX.q, NewY.q, NewW.q, NewH.q)
    OldX.q = Round(NewX * *oldImg\Width / NewW, #PB_Round_Down)
    OldY.q = Round(NewY * *oldImg\Height / NewH, #PB_Round_Down)
    
    OldX1.q = OldX +1
    OldY1.q = OldY +1
    
    If OldX1>*oldImg\Width
      OldX1 = *oldImg\Width
    EndIf
    If OldY1>*oldImg\Height
      OldY1 = *oldImg\Height
    EndIf
    
    
    ;   Debug ""+OldX+"x"+OldY+" > "+newX+"x"+newY
    
    
    
    
    
    
  EndProcedure
  
  Procedure UpScale(*img.IMAGEDIM, SizeMultiplier.d)
    NewW.q = Round(*img\Width * SizeMultiplier, #PB_Round_Down)
    NewH.q = Round(*img\Height * SizeMultiplier, #PB_Round_Down)
    
    *nImg.IMAGEDIM = IMAGEDIM(NewW, NewH)
    X.q = 0
    Y.q = 0
    
    
    For X = 0 To NewW-1 Step 123
      For Y = 0 To NewH-1 Step 123
        *nImg\X(X)\Y(Y)\Color = CalcNewColor(*img, X, Y, NewW, NewH)
        CalcNewColor(*img, X+1, Y+1, NewW, NewH)
        CalcNewColor(*img, X+2, Y+2, NewW, NewH)
      Next
    Next
    
  EndProcedure
  
  Procedure Test1(*image.IMAGEDIM)
    
    X.q = 0
    Y.q = 0
    
    MaxID.q = AssignID(*image)
    
    *newImg = UpScale(*image, 5)
    
    ;   For Y = 0 To *image\Height - 1
    ;     For X = 0 To *image\Width - 1
    ;       *image\X(X)\Y(Y)\Color = ColorMix($FF000000, $FFFFFFFF, *image\X(X)\Y(Y)\Id / MaxID)
    ;     Next
    ;   Next
    ;   
    
  EndProcedure
  
  InFile$ = "D:\MY\img\Chibi+Void+Shepherdess.png"
  InFile$ = "C:\Users\vlad2\Pictures\disk.png"
  
  Debug "Load"
  If LoadImage(0, InFile$)
    Debug "Read"
    *image.IMAGEDIM = ImageToDim(0)
    FreeImage(0)
    Debug "Process"
    Test1(*image)
    Debug "Save"
    SaveIMAGEDIM(*image, "D:\MY\img\out.png")
    Debug "OK"
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 59
; FirstLine = 16
; Folding = ----
; EnableXP