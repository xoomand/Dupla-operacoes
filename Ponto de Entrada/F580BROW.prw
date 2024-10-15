User Function F580BROW()

Local cTipo     := SUPERGETMV("MV_XTPFIN", .T., "FOL")
Local cNatNeg   := SUPERGETMV("MV_XNTFIN", .T., "32101|32102")
Local cFiltro   :=  " E2_FILIAL == '"+fwxFilial("SE2")+"' .AND. (E2_TIPO $ '"+cTipo+"' .OR. E2_NATUREZ $ '"+cNatNeg+"') " 

dbSelectArea("SE2")
Set Filter To &(cFiltro)
SE2->(dbGoTop())

Return(NIL)
