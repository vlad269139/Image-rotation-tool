UsePNGImageDecoder()
UsePNGImageEncoder()
UseJPEGImageDecoder()


XIncludeFile "CanvasViewer.pb"
XIncludeFile "ImageGraph.pb"
XIncludeFile "Tips.pb"
XIncludeFile "UI Help.pb"
XIncludeFile "MathUtils.pb"
XIncludeFile "ImageUpscale.pb"

UseModule UIHelp

;- APP_TAG
Structure APP_TAG
  Image.q
  ShownImage.q
  Filename$
  res.SIZE
  hasChanges.a
  UpdateGraphs.a
  
  Thread.q
EndStructure

Global APP.APP_TAG

;-

Procedure iif(expr, ifTrue, ifFalse)
  If expr
    ProcedureReturn ifTrue
  EndIf
    ProcedureReturn ifFalse
  EndProcedure
  
  
  #APP_SelectionMix = 0.5
  
  Macro colorPart(color)
    If t\RGB\color > 125
    t\RGB\color = Mix(t\RGB\color, 0, #APP_SelectionMix)
  Else
    t\RGB\color = Mix(t\RGB\color, 255, #APP_SelectionMix)
  EndIf
  EndMacro


Procedure.q SelectionFilter(x, y, src.q, targetColor.q)
  
  t.PIXEL\Color = targetColor
  
  
  r.a = Red(targetColor)
  g.a = Green(targetColor)
  b.a = Blue(targetColor)
  
  z.f = (r / 255 + g / 255 + b / 255) / 3
  
  colorPart(Red)
  colorPart(Green)
  colorPart(Blue)
  
  
  ProcedureReturn t\Color
EndProcedure

Procedure.q BWFilter(x, y, src, target.q)
  t.PIXEL\Color = target
  
  z.w = (t\RGB\Red + t\RGB\Green + t\RGB\Blue) / 3
  
  If z > src
    ProcedureReturn #White
  EndIf
  
  ProcedureReturn #Black
  
EndProcedure

Procedure UpdateMainImage()
  img = APP\Image
  If IsImage(img) = 0
    ProcedureReturn 
  EndIf
  
  showImage.q = app\ShownImage
  
  
  If showImage = 0
    showImage = CreateImage(#PB_Any, app\res\cx, APP\res\cy, 24, #Gray) ; CopyImage(APP\Image, #PB_Any)
  EndIf
  
  StartDrawing(ImageOutput(showImage))
  
  DrawImage(ImageID(img), 0,0)
  
  If ui\FilterEnabled_get()
    
    t = ui\FilterTreshold_get()
    
    Debug "BW filter "  + t
    
    
    DrawingMode(#PB_2DDrawing_CustomFilter)      
    CustomFilterCallback(@BWFilter())
    Box(0, 0, APP\res\cx, app\res\cy, t)
    
  EndIf
  
  If ui\ShowSelection_get()
    
    DrawingMode(#PB_2DDrawing_CustomFilter)      
    CustomFilterCallback(@SelectionFilter())
    Box(0, ui\SelectionStart_get(), APP\res\cx, ui\SelectionSize_get())
  EndIf
  StopDrawing()
  
  If APP\ShownImage = 0
    app\ShownImage = showImage
    ui\SetViewImage(showImage)
  Else
    ui\UpdateView()
  EndIf
EndProcedure

Procedure UpdateGraph(y, outputGadget)
  If IsImage(app\Image) = 0
    ProcedureReturn 
  EndIf
  
  
  w = GadgetWidth(outputGadget)
  h = GadgetHeight(outputGadget)
  
  *d.DRAW = DRAW()
  *red.PARAMGRAPH = PARAMGRAPH(#Red, 0, 255, *d)
  *green.PARAMGRAPH = PARAMGRAPH(#Green, 0, 255, *d)
  *blue.PARAMGRAPH = PARAMGRAPH(#Blue, 0, 255, *d)
  
  If y >= 0 And y < APP\res\cy
    ; fill it 
    
    StartDrawing(ImageOutput(app\Image))
      For x = 0 To app\res\cx - 1
        clr.l = Point(x, y)
        PokeD(AddElement(*red\D()), Red(clr))
        PokeD(AddElement(*green\D()), Green(clr))
        PokeD(AddElement(*blue\D()), Blue(clr))
      Next
    StopDrawing()
    
  EndIf
  
  image = DrawDRAW(*d, w, h, #Gray, #False)
  
  freeDRAW(*d)
  
  SetGadgetState(outputGadget, ImageID(image))
  
  FreeImage(image)
  
EndProcedure

Procedure UpdateGraphs()
  
  If app\UpdateGraphs = #False
    ProcedureReturn 
  EndIf
  
  UpdateGraph(ui\SelectionStart_get() - 1, #APP_Controls_TopGraph)
  UpdateGraph(ui\SelectionStart_get(), #APP_Controls_BottomGraph)
EndProcedure

Procedure UpdateViews()
  UpdateMainImage()
  
  If app\UpdateGraphs
    UpdateGraphs()
  EndIf
  
EndProcedure

Procedure AskSaving()
  
  fn$ = GetPathPart(app\Filename$)+"\"+ GetFilePart(app\Filename$, #PB_FileSystem_NoExtension) +" - rotated.png"
  fn$ = SaveFileRequester("Save image", fn$, "PNG image (.png)|*.png", 0)
  If Len(fn$) = 0
    ProcedureReturn 0
  EndIf
  SaveImage(app\Image, fn$)
  
  app\hasChanges = 0
  ProcedureReturn 1
  
EndProcedure


;-


Procedure CheckSave()
  If IsImage(app\Image) = 0
    ProcedureReturn 1
  EndIf
  
  If app\hasChanges = 0
    ProcedureReturn 1
  EndIf
  
  Select MessageRequester("Progress", "Do you want to save progress?", #PB_MessageRequester_YesNoCancel)
    Case #PB_MessageRequester_Yes
      ProcedureReturn AskSaving()
    Case #PB_MessageRequester_No
      ProcedureReturn 1
    Case #PB_MessageRequester_Cancel
      ProcedureReturn 0
  EndSelect
  
  ProcedureReturn 0
EndProcedure



Procedure LoadNewImage(filename$)
  
  If Len(filename$) = 0
    ProcedureReturn
  EndIf 
  
  newImage.q = LoadImage(#PB_Any, filename$)
  
  If newImage = 0
    MessageRequester("Error", "Error occured, can't load this image.")
    ProcedureReturn 
  EndIf
  
  
  If IsImage(APP\Image)
    FreeImage(app\Image)
    APP\Image = 0
  EndIf
  
  If IsImage(app\ShownImage)
    FreeImage(app\ShownImage)
    app\ShownImage = 0
  EndIf
  
  APP\Filename$ = filename$
  APP\Image = newImage
  APP\hasChanges = 0
  
  w = ImageWidth(newImage)
  h = ImageHeight(newImage)
  
  app\res\cx = w
  APP\res\cy = h
  
  ui\MovementSizeMax_set(w)
  ui\SelectionStartMax_set(h - 1)
  
  ui\SelectionStart_set(0)
  ui\SelectionSize_set(1)
  ui\SelectionSizeMax_set(h)
  
  
  
  UpdateViews()
  ui\EnableControls()
  
EndProcedure

Procedure OpenImage()
  
  
  If CheckSave() = 0
;     MessageRequester("Cancel", "Canceled")
    ProcedureReturn 
  EndIf
  
  imageFilename$ = OpenFileRequester("Image to open", "", "Images (*.png, *.jpg)|*.png;*.jpg;*.jpeg", 0)
  
  LoadNewImage(imageFilename$)
EndProcedure


Procedure ReloadImage()
  If IsImage(app\Image) = 0
    ProcedureReturn 
  EndIf
  
  If CheckSave() = 0
    ProcedureReturn 
  EndIf
  
  LoadNewImage(app\Filename$)
  
EndProcedure



Procedure Move(toTheLeft.a = 0)
  start = ui\SelectionStart_get()
  heigth = ui\SelectionSize_get()
  imageW = APP\res\cx
  
  offset = ui\MovementSize_get()
  If toTheLeft
    offset = -offset
  EndIf
  offset = WrapValueL(offset, 1, imageW + 1)
  
  part = GrabImage(APP\Image, #PB_Any, 0, start, APP\res\cx, heigth)
  
  
  StartDrawing(ImageOutput(APP\Image))
  DrawImage(ImageID(part), offset, start)
  DrawImage(ImageID(part), offset - APP\res\cx, start)
  StopDrawing()
  
  FreeImage(part)
  app\hasChanges = #True
  UpdateViews()
  
EndProcedure

Procedure MoveLeft()
  Move(1)
EndProcedure
Procedure MoveRight()
  Move(0)
EndProcedure


;-


Structure OffsetScores
  Offset.q
  Score.q
EndStructure

Procedure CalcScore(*px1.PIXEL, *px2.PIXEL)
  r = AbsDiff(*px1\RGB\Red, (*px2\RGB\Red))
  g = AbsDiff(*px1\RGB\Green, (*px2\RGB\Green))
  b = AbsDiff(*px1\RGB\Blue, (*px2\RGB\Blue))
  ProcedureReturn r + g + b
EndProcedure

Procedure ShiftIMAGEDIM(*img.IMAGEDIM, y, shift.l = 1)
  buff.PIXEL
  
  x = WrapValueL(-shift, 0, *img\Width)
  buff\Color =  *img\X(x)\Y(y)\Color
  Dim copy.PIXEL(*img\Width - 1)
  
  For x = 0 To *img\Width - 1
    copy(x)\Color = *img\X(x)\Y(y)\Color
  Next
  
  For x = 0 To *img\Width - 1
    srcX = WrapValueL(x-shift, 0, *img\Width)
    *img\X(x)\Y(y)\Color = copy(srcX)\Color
  Next
  
  FreeArray(copy())
EndProcedure

Procedure ProcessLine(*img.IMAGEDIM, refY, processingY, setting)
  
  NewList Scores.OffsetScores()
  *sc.OffsetScores = 0
  
  Dim preLine.PIXEL(*img\Width - 1)
  
  For x = 0 To *img\Width - 1
    r.q = 0
    g.q = 0
    b.q = 0
    
    For y = processingY - 1 To processingY - setting Step -1
      r + *img\X(x)\Y(y)\RGB\Red
      g + *img\X(x)\Y(y)\RGB\Green
      b + *img\X(x)\Y(y)\RGB\Blue
    Next
    
    preLine(x)\RGB\Red = r / 3
    preLine(x)\RGB\Green= g / 3
    preLine(x)\RGB\Blue = b / 3
  Next
  
  For xOffset = 0 To *img\Width -1 
    
    *sc= AddElement(Scores())
    *sc\Offset = xOffset
    *sc\Score = 0
    
    For x = 0 To *img\Width - 1
      ; *px1.PIXEL = @*img\X(x)\Y(refY)
      *px1.PIXEL = @preLine(x)
      *px2.PIXEL= @*img\X(x)\Y(processingY)
      
      score = CalcScore(*px1, *px2)
      
      *sc\Score + score
    Next
    
;     SaveIMAGEDIM(*img, "Y:\PB\ARG\images\shift Test\"+processingY +"x"+ xOffset+".png")
    
    ShiftIMAGEDIM(*img, processingY)
  Next
  
  
  FreeArray(preLine())
;   ClearDebugOutput()
;   ForEach Scores()
;     Debug "> "+ Scores()\Offset +" - "+ Scores()\Score
;   Next
  
  SortStructuredList(Scores(), #PB_Sort_Ascending, OffsetOf(OffsetScores\Score), #PB_Quad)
  *sc = FirstElement(Scores())
  ; *bad.OffsetScores = LastElement(Scores())
  o = *sc\Offset
  ShiftIMAGEDIM(*img, processingY, o)
  
  ; Debug "" + processingY +" : "+*sc\Offset +"px - "+ *sc\Score +" (vs "+ *bad\Score+")"
  FreeList(Scores())
  ProcedureReturn o
EndProcedure


Procedure Automatic(setting)
  If IsImage(app\Image) = 0
    ProcedureReturn 
  EndIf
  APP\UpdateGraphs = #False
  ui\DisableControls(#False)
  
  img = app\Image
  *img.IMAGEDIM = ImageToDim(img)
  
  
  
  
  
  initialStart = ui\SelectionStart_get()
  initialSize = ui\SelectionSize_get()
  initMove = ui\MovementSize_get()
  
  
  ui\SelectionSize_set(1)
  
  
  startY.q = setting
  endY.q = *img\Height - 1
  
  If ui\AutoSelectionOnly_get()
    
    startY = initialStart
    endY = initialStart + initialSize - 1
    
    If startY < setting
      startY = setting
    EndIf
    
    If endY >= *img\Height
      endY = *img\Height - 1
    EndIf
    
  EndIf
  
  SetGadgetText(#APP_Controls_Automatic, "Stop")
  
  
  For y = startY To endY
    prevY = y - 1
    ui\SelectionStart_set(y)
    
    
;     UpdateMainImage()
    
    offset = ProcessLine(*img, prevY, y, setting)
    
    If offset <> 0
      ui\MovementSize_set(offset)
      MoveRight()
    
    EndIf
    
    
    
  Next
  
  
  
  APP\UpdateGraphs = #True
  
  FreeIMAGEDIM(*img)
  
  
  ui\SelectionStart_set(initialStart)
  ui\SelectionSize_set(initialSize)
  ui\MovementSize_set(initMove)
  UpdateViews()
  
  
  ui\EnableControls()
  
  
EndProcedure

Procedure StartAutomatic()
  
  
  APP\Thread = CreateThread(@Automatic(), ui\GetAutomaticSetting())
  
EndProcedure





;-===================================
;- Main Window



Procedure OnOpenImageBtn()
  OpenImage()
EndProcedure

Procedure OnReloadImageBtn()
  ReloadImage()
EndProcedure

Procedure OnMoveLeftBtn()
  MoveLeft()
EndProcedure

Procedure OnMoveRightBtn()
  MoveRight()
EndProcedure

Procedure OnSelectionChangeCB()
  Debug "selection changed"
  ui\SelectionSizeMax_set(APP\res\cy - ui\SelectionStart_get())
  UpdateViews()
EndProcedure


Procedure OnSelectionVisibilityChange()
  UpdateViews()
EndProcedure


Procedure OnBWfilterChanged()
  UpdateViews()
EndProcedure


;- shortcuts

Enumeration SomeEvents
  #APP_Event_SelectionMoveUp
  #APP_Event_SelectionMoveDown
  
  #APP_Event_SelectionSizeUp
  #APP_Event_SelectionSizeDown
  
  #APP_Event_MoveLeft
  #APP_Event_MoveRight
  
  #APP_Event_MovementSizeUp
  #APP_Event_MovementSizeDown
  
  #APP_Event_SwitchSelection
  
  #APP_Event_ReloadImage
  #APP_Event_OpenImage
  #APP_Event_SaveImage
  
  #APP_Event_test
EndEnumeration

Procedure SwitchSelectionVisibility()
  ui\ShowSelection_set(1 - ui\ShowSelection_get())
  UpdateViews()
EndProcedure

Procedure OnMoveSelectionUp()
  x.q = ui\SelectionStart_get()
  If x > 0
    x - 1
    EndIf
    ui\SelectionStart_set(x)
    UpdateViews()
EndProcedure

Procedure OnMoveSelectionDown()
  x.q = ui\SelectionStart_get()
  If x < ui\SelectionStartMax_get()
    x + 1
  EndIf
  
  ui\SelectionStart_set(x)
  UpdateViews()
EndProcedure

Procedure OnIncreaseSelectionSize()
  s = ui\SelectionSize_get()
  If s < ui\SelectionSizeMax_get() 
    s + 1
  EndIf
  
  ui\SelectionSize_set(s)
  UpdateViews()
EndProcedure

Procedure OnDecreaseSelectionSize()
  s = ui\SelectionSize_get()
  If s > 0 
    s - 1
  EndIf
  
  ui\SelectionSize_set(s)
  UpdateViews()
EndProcedure

Procedure DecreaseMovementSize()
  x = ui\MovementSize_get()
  Debug "DecreaseMovementSize: "+ x
  If x > 1
    x - 1
  EndIf
  ui\MovementSize_set(x)
EndProcedure
Procedure IncreaseMovementSize()
  x = ui\MovementSize_get()
  
  Debug "IncreaseMovementSize: "+ x +" / "+ ui\MovementSizeMax_get()
  
  If x < ui\MovementSizeMax_get()
    x + 1
  EndIf
  
  ui\MovementSize_set(x)
EndProcedure

;-

Procedure MainWindowResize()
  winW.l = WindowWidth(#APP_MainWindow)
  winH.l = WindowHeight(#APP_MainWindow)
  
  
  rightBarWidth = 260
  bottomGraphsHeight = 200
  x = 5
  y = 5
  
  txtSizes = 18
  afterTXTmargin = 2
  
  ResizeGadget(#APP_Controls_ImageCanvas, 5, 5, 
               winW - rightBarWidth - 20, winH - bottomGraphsHeight - 20)
  
  x = winW - rightBarWidth + 5
  ResizeGadget(#APP_Controls_ControlGroup, NextGadgetX(#APP_Controls_ImageCanvas, 10), 5,
               rightBarWidth, GadgetHeight(#APP_Controls_ImageCanvas))
  
  rightBarWidth = rightBarWidth - 20
  y = GadgetY(#APP_Controls_ControlGroup) + 20
  
  tmpW = Div_Width(rightBarWidth, 2)
  
  ResizeGadget(#APP_Controls_OpenImage, x, y, tmpW, 25)
  ResizeGadget(#APP_Controls_ReloadImage, NextGadgetX(#APP_Controls_OpenImage), y, tmpW, 25)
  
  y = NextGadgetY(#APP_Controls_OpenImage, 10)
  
  
;     
;     #APP_txt_MovementSize
;     #APP_txt_AutoLookup
;     #APP_txt_BW_tres
  
  x = 0
  
  y = 0; NextGadgetY(#APP_Controls_OpenImage, 15)
  
  ;rightBarWidth - 2
  ResizeGadget(#APP_txt_SelectionStart, x, y, rightBarWidth, txtSizes )
  ResizeGadget(#APP_Controls_StartSelectionSpin, x, NextGadgetY(#APP_txt_SelectionStart, afterTXTmargin), rightBarWidth, 25)
  
  
  ResizeGadget(#APP_txt_SelectionSize, x, NextGadgetY(#APP_Controls_StartSelectionSpin, 10), rightBarWidth, txtSizes )
  ResizeGadget(#APP_Controls_SelectionSizeSpin, x, NextGadgetY(#APP_txt_SelectionSize, afterTXTmargin), rightBarWidth, 25)
  
  ResizeGadget(#APP_Controls_ShowSelectionCheck, x, NextGadgetY(#APP_Controls_SelectionSizeSpin), rightBarWidth, 20)
  
  y  = NextGadgetY(#APP_Controls_ShowSelectionCheck, 15)
  
  ResizeGadget(#APP_Controls_Filter_enable, x, y, rightBarWidth, 25)
  ResizeGadget(#APP_txt_BW_tres, x, NextGadgetY(#APP_Controls_Filter_enable), rightBarWidth, txtSizes )
  ResizeGadget(#APP_Controls_Filter_size, x, NextGadgetY(#APP_txt_BW_tres, afterTXTmargin), rightBarWidth, 30)
  
  y  = NextGadgetY(#APP_Controls_Filter_size, 15)
  
  ResizeGadget(#APP_txt_MovementSize, x, y, rightBarWidth, txtSizes)
  ResizeGadget(#APP_Controls_MovementSizeSpin, x, NextGadgetY(#APP_txt_MovementSize, afterTXTmargin), rightBarWidth, 25)
  y  = NextGadgetY(#APP_Controls_MovementSizeSpin)
  ResizeGadget(#APP_Controls_MoveLeftButton, x, y, Div_Width(rightBarWidth, 2), 25)
  ResizeGadget(#APP_Controls_MoveRightButton, NextGadgetX(#APP_Controls_MoveLeftButton), y, Div_Width(rightBarWidth, 2), 25)
  
  y = NextGadgetY(#APP_Controls_MoveLeftButton, 15)
  
  ResizeGadget(#APP_txt_AutoLookup, x, y, Div_Width(rightBarWidth, 2), txtSizes)
  ResizeGadget(#APP_Controls_AutoSetting, NextGadgetX(#APP_txt_AutoLookup), y, Div_Width(rightBarWidth, 2), 25)
  
  y = NextGadgetY(#APP_Controls_AutoSetting)
  
  ResizeGadget(#APP_Controls_Automatic, x, y, rightBarWidth - x, 25)
  
  y = NextGadgetY(#APP_Controls_Automatic, 5)
  ResizeGadget(#APP_Controls_Auto_SelectionOnly, x,y,rightBarWidth, 25)
  
  y = NextGadgetY(#APP_Controls_Auto_SelectionOnly, 20)
  ResizeGadget(#APP_Controls_SaveImage, x, y, rightBarWidth, 30)
  
  
  ResizeGadget(#App_Controls_ControlsPanel, GadgetX(#APP_Controls_OpenImage), NextGadgetY(#APP_Controls_OpenImage, 10), 
               rightBarWidth, GadgetHeight(#APP_Controls_ControlGroup) - GadgetHeight(#APP_Controls_OpenImage) - 35)
  
  x = 5
  y = NextGadgetY(#APP_Controls_ImageCanvas, 10)
  tmpW = winW - 10
  tmpH = Div_Height(bottomGraphsHeight, 2)
  ResizeGadget(#APP_Controls_TopGraph, x, y, tmpW, tmpH)
  ResizeGadget(#APP_Controls_BottomGraph, x, NextGadgetY(#APP_Controls_TopGraph), tmpW, tmpH)
  
  
  UpdateGraphs()
  
EndProcedure




;-

Macro ShortcutCallBack(window, keys, menuEvent, callback)
  
  AddKeyboardShortcut(window, keys, menuEvent)
  BindEvent(#PB_Event_Menu, callback, window, menuEvent)
  
EndMacro

Procedure TestDisable()
  ui\DisableControls()
EndProcedure

Procedure TestDisable2()
  ui\DisableControls(#False)
EndProcedure



Procedure MainWindow()
  OpenWindow(#APP_MainWindow, 0, 0, 800, 800, "Rotate image", #PB_Window_ScreenCentered | #PB_Window_SizeGadget | 
                                                              #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget)
  
  CanvasGadget(#APP_Controls_ImageCanvas, 0,0,0,0,0)
  CanvasViewer::CreateCanvasViewer(#APP_Controls_ImageCanvas)
  
  ImageGadget(#APP_Controls_TopGraph, 0, 0, 0, 0, 0)
  ImageGadget(#APP_Controls_BottomGraph, 0, 0, 0, 0, 0)
  
  FrameGadget(#APP_Controls_ControlGroup, 0,0,0,0,"Controls")
  
  ButtonGadget(#APP_Controls_OpenImage, 0,0,0,0,"Open image")
  ButtonGadget(#APP_Controls_ReloadImage, 0,0,0,0, "Reload")
  
  ContainerGadget(#App_Controls_ControlsPanel, 0,0,0,0) ; , #PB_Container_Single)
  ButtonGadget(#APP_Controls_SaveImage, 0,0,0,0,"Save")
  ; should be updated, based ion image size
  ; selection.start.max = ImageHeight() - 1
  ; selection.size.max = selection.start.max - selection.start.value
  TextGadget(#APP_txt_SelectionStart, 0,0,0,0, "Selection line:")
  SpinGadget(#APP_Controls_StartSelectionSpin, 0,0,0,0, 0,1, #PB_Spin_Numeric)
  SetGadgetState(#APP_Controls_StartSelectionSpin, 0)
  GadgetToolTip(#APP_Controls_StartSelectionSpin, "Shortcut - UP an DOWN arrows")
  
  TextGadget(#APP_txt_SelectionSize, 0,0,0,0, "Selection size:")
  SpinGadget(#APP_Controls_SelectionSizeSpin,0,0,0,0, 1,2, #PB_Spin_Numeric)
  SetGadgetState(#APP_Controls_SelectionSizeSpin, 1)
  SetGadgetText(#APP_Controls_SelectionSizeSpin, "1")
  GadgetToolTip(#APP_Controls_SelectionSizeSpin, "Shortcut - Ctrl+Up/Down arrows")
  
  CheckBoxGadget(#APP_Controls_ShowSelectionCheck, 0,0,0,0, "Show selection")
  SetGadgetState(#APP_Controls_ShowSelectionCheck, 1)
  
  
  CheckBoxGadget(#APP_Controls_Filter_enable, 0,0,0,0, "B&W")
  TextGadget(#APP_txt_BW_tres, 0,0,0,0, "B&W Threshold:")
  TrackBarGadget(#APP_Controls_Filter_size, 0,0,0,0,-1,255)
  
  
  ; movementSize.min = 0
  ; movementSize.max = ImageWidth()
  
  TextGadget(#APP_txt_MovementSize, 0,0,0,0, "Movement size:")
  SpinGadget(#APP_Controls_MovementSizeSpin, 0,0,0,0,1,1000, #PB_Spin_Numeric)
  GadgetToolTip(#APP_Controls_MovementSizeSpin, "Shortcut - Shift + Up/Down arrow")
  SetGadgetState(#APP_Controls_MovementSizeSpin, 1)
  SetGadgetText(#APP_Controls_MovementSizeSpin, "1")
  
  ButtonGadget(#APP_Controls_MoveLeftButton, 0,0,0,0, "<-")
  ButtonGadget(#APP_Controls_MoveRightButton, 0,0,0,0, "->")
  GadgetToolTip(#APP_Controls_MoveLeftButton, "Short - Left arrow.")
  GadgetToolTip(#APP_Controls_MoveRightButton, "Short - Right arrow.")
  
  TextGadget(#APP_txt_AutoLookup, 0,0,0,0, "Auto lookup:")
  SpinGadget(#APP_Controls_AutoSetting, 0,0,0,0, 1,10, #PB_Spin_Numeric)
  GadgetToolTip(#APP_Controls_AutoSetting, "Amount of pixels above to watch")
  SetGadgetState(#APP_Controls_AutoSetting, 1)
  SetGadgetText(#APP_Controls_AutoSetting, "1")
  ButtonGadget(#APP_Controls_Automatic, 0,0,0,0, "Auto")
  
  CheckBoxGadget(#APP_Controls_Auto_SelectionOnly, 0,0,0,0,"Selection Only")
  
  MainWindowResize()
  
  
  ui\DisableControls()
  
  
  BindEvent(#PB_Event_SizeWindow, @MainWindowResize(), #APP_MainWindow)
  
  ;; BindEvent(#PB_Event_SizeWindow, @UpdateGraphs(), #APP_MainWindow)
  
  BindEvent(#PB_Event_Gadget, @OnOpenImageBtn(), #APP_MainWindow, #APP_Controls_OpenImage, #PB_EventType_LeftClick)
  BindEvent(#PB_Event_Gadget, @ReloadImage(), #APP_MainWindow, #APP_Controls_ReloadImage, #PB_EventType_LeftClick)
  BindEvent(#PB_Event_Gadget, @AskSaving(), #APP_MainWindow, #APP_Controls_SaveImage, #PB_EventType_LeftClick)
  
  BindEvent(#PB_Event_Gadget, @OnSelectionChangeCB(), #APP_MainWindow, #APP_Controls_StartSelectionSpin, #PB_EventType_Change)
  BindEvent(#PB_Event_Gadget, @OnSelectionChangeCB(), #APP_MainWindow, #APP_Controls_SelectionSizeSpin, #PB_EventType_Change)
  
  BindEvent(#PB_Event_Gadget, @OnSelectionVisibilityChange(), #APP_MainWindow, #APP_Controls_ShowSelectionCheck)
  
  BindEvent(#PB_Event_Gadget, @OnMoveLeftBtn(), #APP_MainWindow, #APP_Controls_MoveLeftButton)
  BindEvent(#PB_Event_Gadget, @OnMoveRightBtn(), #APP_MainWindow, #APP_Controls_MoveRightButton)
  
  
  BindEvent(#PB_Event_Gadget, @StartAutomatic(), #APP_MainWindow, #APP_Controls_Automatic)
  
  
  BindEvent(#PB_Event_Gadget, @OnBWfilterChanged(), #APP_MainWindow, #APP_Controls_Filter_enable)
  BindEvent(#PB_Event_Gadget, @OnBWfilterChanged(), #APP_MainWindow, #APP_Controls_Filter_size)
  
  
  AddKeyboardShortcut(#APP_MainWindow, #PB_Shortcut_Up, #APP_Event_SelectionMoveUp)
  BindEvent(#PB_Event_Menu, @OnMoveSelectionUp(), #APP_MainWindow, #APP_Event_SelectionMoveUp)
  
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Down, #APP_Event_SelectionMoveDown, @OnMoveSelectionDown())
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Down | #PB_Shortcut_Control, #APP_Event_SelectionSizeUp, @OnIncreaseSelectionSize())
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Up | #PB_Shortcut_Control, #APP_Event_SelectionSizeDown, @OnDecreaseSelectionSize())
  
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Left, #APP_Event_MoveLeft, @OnMoveLeftBtn())
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Right, #APP_Event_MoveRight, @OnMoveRightBtn())
  
  
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Down | #PB_Shortcut_Shift, #APP_Event_MovementSizeDown, @DecreaseMovementSize())
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Up | #PB_Shortcut_Shift, #APP_Event_MovementSizeUp, @IncreaseMovementSize())
  
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_V , #APP_Event_SwitchSelection, @SwitchSelectionVisibility())
  
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Control |#PB_Shortcut_S, #APP_Event_SaveImage, @AskSaving())
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Control |#PB_Shortcut_O, #APP_Event_OpenImage, @OnOpenImageBtn())
  ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Control |#PB_Shortcut_R, #APP_Event_ReloadImage, @ReloadImage())
  
  
  
  
;   ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Control |#PB_Shortcut_E, 100, @ui\EnableControls())
;   ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Control |#PB_Shortcut_D, 101, @TestDisable())
;   ShortcutCallBack(#APP_MainWindow, #PB_Shortcut_Control |#PB_Shortcut_F, 102, @TestDisable2())
EndProcedure

Procedure MainWindowLoop()
  Repeat
    e = WaitWindowEvent()
    
    Select e
      Case #PB_Event_CloseWindow
        If CheckSave()
          Break
        EndIf
    EndSelect
  ForEver
  
        If IsThread(app\Thread)
          KillThread(app\Thread)
        EndIf
EndProcedure


Procedure main()
  
  APP\UpdateGraphs = #True
  
  PrepareUI()
  MainWindow()
  MainWindowLoop()
EndProcedure

main()
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 6
; Folding = --------
; EnableXP
; EnableUnicode