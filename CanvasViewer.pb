


DeclareModule CanvasViewer
  Declare CreateCanvasViewer(canvas)
  Declare SetCanvasImage(canvas, image)
  Declare ResetCanvasView(canvas)
  Declare RedrawCanvasView(canvas)
EndDeclareModule


Module CanvasViewer
  #CV_Property = "pViewer"
  
  
  
  Structure POINTD 
    X.d 
    Y.d
  EndStructure
  Structure VIEWER
    Center.POINTD 
    Scale.d 
    ;  ShownImage.q 
    OriginalImage.q 
    Resolution.SIZE
    
    Mutex.q
    
    LastCursorPosition.POINT
  EndStructure 
  
  Procedure SetProp(hWnd.l, prop$, value.l)
    SetProp_(hWnd, prop$, value)
  EndProcedure
  Procedure.l GetProp(hWnd.l, prop$)
    ProcedureReturn GetProp_(hWnd, prop$)
  EndProcedure 
  
  Procedure SetGadgetLong(gadget, value.l)
    SetProp(GadgetID(gadget), #CV_Property, value)
  EndProcedure 
  
  Procedure.l GetGadgetLong(gadget)
    ProcedureReturn GetProp(GadgetID(gadget), #CV_Property)
  EndProcedure
  
  
  Structure DIMENSION
    gadgetSize.SIZE
    drawStart.POINT
    crop.SIZE
    cropStart.POINT
  EndStructure
  
  
  Procedure Update2(canvas, *d.VIEWER)
    If *d = 0
      ProcedureReturn 
    EndIf
    With *d
      If IsImage(\OriginalImage) = 0
        ProcedureReturn 
      EndIf
      LockMutex(\Mutex)
      
      Protected.POINT drawAt, cropStart, imageCenter
      Protected.SIZEL gadgetSize, crop, viewWindow
      
      
      Protected.DIMENSION image, gadget
      
      gadget\gadgetSize\cx = GadgetWidth(canvas)
      gadget\gadgetSize\cy = GadgetHeight(canvas)
      
      image\gadgetSize\cx = gadget\gadgetSize\cx * \Scale
      image\gadgetSize\cy = gadget\gadgetSize\cy * \Scale
      
      imageCenter\x = \Resolution\cx * \Center\X
      imageCenter\y = \Resolution\cy * \Center\Y
      
      image\crop\cx = image\gadgetSize\cx
      image\crop\cy = image\gadgetSize\cy
      
      image\cropStart\x = imageCenter\x - image\gadgetSize\cx / 2
      image\cropStart\y = imageCenter\y - image\gadgetSize\cy / 2
      
      If image\cropStart\x < 0 
        image\crop\cx + image\cropStart\x
        image\drawStart\x = -image\cropStart\x
        image\cropStart\x = 0
      EndIf
      If (image\cropStart\x + image\crop\cx) > *d\Resolution\cx
        image\crop\cx = *d\Resolution\cx - image\cropStart\x
      EndIf
      
      If image\cropStart\y < 0 
        image\crop\cy + image\cropStart\y
        image\drawStart\y = -image\cropStart\y
        image\cropStart\y = 0 
      EndIf
      If (image\cropStart\y + image\crop\cy) > \Resolution\cy
        image\crop\cy = \Resolution\cy - image\cropStart\y
      EndIf
      
      
      If image\drawStart\x <> 0
        gadget\drawStart\x = image\drawStart\x / \Scale
      EndIf
      If image\drawStart\y <> 0
        gadget\drawStart\y = image\drawStart\y / \Scale
      EndIf
      gadget\crop\cx = image\crop\cx / \Scale
      gadget\crop\cy = image\crop\cy / \Scale
      
      cropedImage = GrabImage(\OriginalImage, #PB_Any, image\cropStart\x, image\cropStart\y, image\crop\cx, image\crop\cy)
      
      ResizeImage(cropedImage, gadget\crop\cx, gadget\crop\cy, #PB_Image_Raw)
      
      resultImage = CreateImage(#PB_Any, gadget\gadgetSize\cx, gadget\gadgetSize\cy, 24, #Gray)
      StartDrawing(ImageOutput(resultImage))
      DrawImage(ImageID(cropedImage),
                gadget\drawStart\x, gadget\drawStart\y)
      StopDrawing()
      
      
      FreeImage(cropedImage)
      
      SetGadgetAttribute(canvas, #PB_Canvas_Image, ImageID(resultImage))
      
      FreeImage(resultImage)
      
      
      
      
      UnlockMutex(\Mutex)
    EndWith
    
  EndProcedure
  
  ; 
  ; Procedure Update(canvas, *d.VIEWER)
  ;   Update2(canvas, *d)
  ;   
  ;   ProcedureReturn 
  ;   
  ;   
  ;   Protected centre.POINT
  ;   Protected crop.SIZE
  ;   Protected imageStart.POINT
  ;   Protected drawingStart.POINT
  ;   
  ;   
  ;   
  ;   
  ;   If *d = 0
  ;     ProcedureReturn 
  ;   EndIf
  ;   
  ;   With *d
  ;     LockMutex(*d\Mutex)
  ;     
  ;     If IsImage(*d\OriginalImage)
  ;       
  ;       
  ;       
  ;       gadgetW.l = GadgetWidth(canvas)
  ;       gadgetH.l = GadgetHeight(canvas)
  ;       
  ;       ;     visibleH = h * *d\Scale 
  ;       ;     visibleW = w * *d\Scale 
  ;       ;     
  ;       ;     x.l = *d\Center\X * *d\Resolution\cx ;- visibleW/2 
  ;       ;     y.l = *d\Center\Y * *d\Resolution\cy ;- visibleH/2 
  ;       
  ;       
  ;       centre\x = *d\Center\X * \Resolution\cx
  ;       centre\y = \Center\Y * \Resolution\cy
  ;       
  ;       crop\cx = gadgetW * \Scale
  ;       crop\cy = gadgetH * \Scale
  ;       
  ;       imageStart\x = centre\x - crop\cx / 2
  ;       imageStart\y = centre\y - crop\cy / 2
  ;       
  ;       If imageStart\x < 0
  ;         crop\cx + imageStart\x
  ;         drawingStart\x = -imageStart\x * \Scale
  ;         imageStart\x = 0
  ;       EndIf
  ;       
  ;       If imageStart\y < 0
  ;         crop\cy + imageStart\y
  ;         drawingStart\y = -imageStart\y * \Scale
  ;         imageStart\y = 0
  ;       EndIf
  ;       
  ;       
  ; ;       Debug "draw: " + centre\x +"x"+centre\y+" | "+ crop\cx +"x"+ crop\cy
  ;       
  ;       
  ;       img = GrabImage(\OriginalImage, #PB_Any, imageStart\x, imageStart\y, crop\cx, crop\cy)
  ;       
  ;       
  ;       img2 = CreateImage(#PB_Any, gadgetW, gadgetH, 24, $808080)
  ;       StartDrawing(ImageOutput(img2))
  ;       DrawImage(ImageID(img), drawingStart\x, drawingStart\y)
  ;       StopDrawing()
  ;       
  ;       FreeImage(img)
  ;       
  ;       
  ;       
  ;       SetGadgetAttribute(canvas, #PB_Canvas_Image, ImageID(img2))
  ;           
  ;       FreeImage(img2) ; manual said it can be freed after setting attibute...
  ;       
  ;       
  ;       
  ;       
  ;       
  ;       ;; newImage = GrabImage(*d\OriginalImage, #PB_Any, x, y, visibleW, visibleH)
  ;       
  ;       ;     img = CreateImage(#PB_Any, w, h, 32, #White)
  ;       ;     StartDrawing(ImageOutput(img))
  ;       ;     DrawImage(ImageID(*d\OriginalImage), -x, -y, *d\Resolution\cx / *d\Scale, *d\Resolution\cy / *d\Scale)
  ;       ;     StopDrawing()
  ;       
  ;       
  ;       ;     SetGadgetAttribute(canvas, #PB_Canvas_Image, ImageID(img))
  ;       ;     
  ;       ;     FreeImage(img) ; manual said it can be freed after setting attibute...
  ;       
  ;       
  ;     EndIf
  ;     
  ;     UnlockMutex(*d\Mutex)
  ;   EndWith
  ; EndProcedure 
  
  
  
  Procedure MouseWheel_CB()
    ; Debug "wheeeeel"
    g = EventGadget()
    *mem.VIEWER = GetGadgetLong(g)
    delta = GetGadgetAttribute(g, #PB_Canvas_WheelDelta)
    scale.d = Pow(0.9, delta)
    
    *mem\Scale = *mem\Scale * scale
    
    ;   Debug "new scale: "+ *mem\Scale
    Update2(g, *mem)
  EndProcedure
  
  
  Procedure.d Clamp(value.d, min.d, max.d)
    If value < min
      value = min
    ElseIf value > max
      value = max
    EndIf
    
    ProcedureReturn value
    
  EndProcedure
  
  
  Procedure MouseMove_CB()
    ; Debug "mouse move"
    
    g = EventGadget()
    x = GetGadgetAttribute(g, #PB_Canvas_MouseX)
    y = GetGadgetAttribute(g, #PB_Canvas_MouseY)
    
    *m.VIEWER = GetGadgetLong(g)
    
    dX = *m\LastCursorPosition\x - x
    dY = *m\LastCursorPosition\y - y
    
    dXd.d = (dX * *m\Scale) / *m\Resolution\cx
    dYd.d = (dY * *m\Scale) / *m\Resolution\cy
    
    ;   Debug "move " + dX +"x"+dY +" -> "+ dXd +"x"+dYd
    
    
    
    *m\Center\X = *m\Center\X + dXd
    *m\Center\Y = *m\Center\Y + dYd
    
    *m\Center\X = Clamp(*m\Center\X, 0,1)
    *m\Center\Y = Clamp(*m\Center\Y, 0,1)
    
    
    *m\LastCursorPosition\x = x
    *m\LastCursorPosition\y = y
    Update2(g, *m)
  EndProcedure
  
  
  
  Procedure FindGadgetWindow(gadget)
    hWnd = GadgetID(gadget)
    While GetProp_(hWnd, "PB_WINDOWID") = 0
      hWnd = GetParent_(hWnd)
    Wend
    ProcedureReturn GetProp_(hWnd, "PB_WINDOWID") - 1
  EndProcedure
  
  
  
  Procedure MouseLeftButtonUp_CB()
    ;   Debug "Left button up"
    
    g = EventGadget()
    UnbindEvent(#PB_Event_Gadget, @MouseLeftButtonUp_CB(), FindGadgetWindow(g), g, #PB_EventType_LeftButtonUp)
    UnbindEvent(#PB_Event_Gadget, @MouseMove_CB(), FindGadgetWindow(g), g, #PB_EventType_MouseMove)
  EndProcedure
  
  Procedure MouseLeftButtonDown_CB()
    ;   Debug "Left button down"
    g = EventGadget()
    BindEvent(#PB_Event_Gadget, @MouseLeftButtonUp_CB(), FindGadgetWindow(g), g, #PB_EventType_LeftButtonUp)
    BindEvent(#PB_Event_Gadget, @MouseMove_CB(), FindGadgetWindow(g), g, #PB_EventType_MouseMove)
    
    x = GetGadgetAttribute(g, #PB_Canvas_MouseX)
    y = GetGadgetAttribute(g, #PB_Canvas_MouseY)
    
    *m.VIEWER = GetGadgetLong(g)
    
    *m\LastCursorPosition\X = x
    *m\LastCursorPosition\Y = y
    
  EndProcedure
  
  Procedure.d CalcScaleToFit(*image.SIZE, *window.SIZE)
    xScale.d = *image\cx / *window\cx
    yScale.d = *image\cy / *window\cy
    
    If xScale > yScale
      ProcedureReturn xScale
    EndIf
    
    ProcedureReturn yScale
    
  EndProcedure
  
  
  Procedure privResetView(canvas, *v.VIEWER)
    With *v
      \Center\X = 0.5
      \Center\Y = 0.5
      Protected.SIZE gadget
      gadget\cx = GadgetWidth(canvas)
      gadget\cy = GadgetHeight(canvas)
      
      \Scale = CalcScaleToFit(@\Resolution, @gadget)
    EndWith
  EndProcedure
  
  Procedure MouseWheelButton_CB()
    g = EventGadget()
    *m.VIEWER = GetGadgetLong(g)
    
    With *m
      
      If \Scale = 1
        ; then fit it into gadget
        privResetView(g, *m)
      Else
        \Scale = 1
      EndIf
      
    EndWith
    
    Update2(g, *m)
  EndProcedure
  
  Procedure Resize_CB()
    g = EventGadget()
    *m.VIEWER = GetGadgetLong(g)
    Update2(g, *m)
  EndProcedure
  
  
  Procedure CreateCanvasViewer(canvas)
    
    If GadgetType(canvas) <> #PB_GadgetType_Canvas
      ProcedureReturn 0
    EndIf
    
    *mem.VIEWER = AllocateMemory(SizeOf(VIEWER))
    With *mem
      \Mutex = CreateMutex()
      \Scale = 1
      \Center\X = 0.5
      \Center\Y = 0.5
    EndWith
    
    SetGadgetLong(canvas, *mem)
    
    win = FindGadgetWindow(canvas)
    
    ;   Debug "window - " + win
    
    BindEvent(#PB_Event_Gadget, @MouseLeftButtonDown_CB(), win, canvas, #PB_EventType_LeftButtonDown)
    BindEvent(#PB_Event_Gadget, @MouseWheel_CB(), win, canvas, #PB_EventType_MouseWheel)
    
    BindEvent(#PB_Event_Gadget, @MouseWheelButton_CB(), win, canvas, #PB_EventType_MiddleButtonUp)
    BindEvent(#PB_Event_Gadget, @Resize_CB(), win, canvas, #PB_EventType_Resize)
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure SetCanvasImage(canvas, image)
    *m.VIEWER = GetGadgetLong(canvas)
    
    If *m = 0
      ProcedureReturn 0
    EndIf
    
    If IsImage(image) = 0
      ProcedureReturn 0
    EndIf
    
    
    *m\OriginalImage = image
    *m\Resolution\cx = ImageWidth(image)
    *m\Resolution\cy = ImageHeight(image)
    
    Update2(canvas,  *m)
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure ResetCanvasView(canvas)
    *m = GetGadgetLong(canvas)
    If *m = 0
      ProcedureReturn 0
    EndIf
    
    privResetView(canvas, *m)
    Update2(canvas, *m)
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure RedrawCanvasView(canvas)
    *m = GetGadgetLong(canvas)
    If *m = 0
      ProcedureReturn 0
    EndIf
    Update2(canvas, *m)
  EndProcedure
  
EndModule
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 379
; FirstLine = 349
; Folding = ----
; EnableXP
; DPIAware