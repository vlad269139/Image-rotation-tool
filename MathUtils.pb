

Procedure.l WrapValueL(value.l, min.l, max.l)
  diff = max - min
  x.l = (((value - min) % diff) + diff) % diff + min
  ProcedureReturn x
EndProcedure

Procedure.d RemapD(inMin.d, inMax.d, outMin.d, outMax.d, value.d, clamp.a = #False)
  pos.d = (value - inMin) / (inMax - inMin)
  result.d = outMin + (inMax - inMin) * pos
  
  If clamp
    If result > outMax
      result = outMax
    EndIf
    If result < outMin
      result = outMin
    EndIf
  EndIf
  
  ProcedureReturn result
EndProcedure

Procedure.d Mix(val1, val2, mix.d)
  ProcedureReturn val1 * (1-mix) + val2 * mix
EndProcedure
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 26
; Folding = -
; EnableXP
; DPIAware