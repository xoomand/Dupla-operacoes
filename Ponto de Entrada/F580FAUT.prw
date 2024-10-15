#Include 'Protheus.ch'
User Function F580FAUT()
  
Local cTipo     := SUPERGETMV("MV_XTPFIN", .T., "FOL")
Local cNatNeg   := SUPERGETMV("MV_XNTFIN", .T., "32101|32102")
  
cFiltro := ' (E2_TIPO IN '+FormatIn(Alltrim(cTipo), '|')+' OR E2_NATUREZ IN '+FormatIn(Alltrim( cNatNeg), '|') +') '

Return(cFiltro)
