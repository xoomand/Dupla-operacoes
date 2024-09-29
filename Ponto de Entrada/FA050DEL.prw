#Include "rwmake.ch"
#Include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"

////André - Tratando deleção com aprovadores
****************************
User Function FA050DEL()
****************************
Local lret      := .T.
Local cNumDoc   := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)

//Verifica se o título já tem aprovador
lret    := fTemAprov() 

If !lret
    aviso("Atenção","Esse título já teve aprovação por parte de gestores, solicite o estorno da aprovação para poder excluir o título",{"OK"})
    Return(lRet)
else
    fDelSCRFN()
ENDIF

If lret        
    cUpdate	:= " UPDATE " + RetSqlName("SCR") +" "
    cUpdate	+= " SET D_E_L_E_T_ = '*' 
    cUpdate	+= " WHERE CR_NUM  = '"+cNumDoc+"' "
    cUpdate	+= " AND D_E_L_E_T_ = '' "

    nRet := TcSqlExec(cUpdate) 
    if nRet < 0 
        Alert(Time() +  "Erro: " + TCSQLError() )
    endif
Endif

Return(lret)
***************************
Static Function fTemAprov()
****************************
Local cQuery    := ""
Local cTab      := GetNextAlias()
Local cTitulo   := ""
Local lRetAPV   := .T.

cTitulo := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)

cQuery  := " SELECT count(*) AS TEMAPV FROM "+ RETSQLNAME("SCR") + " A "
cQuery  += " WHERE D_E_L_E_T_ = ''
cQuery  += " AND CR_FILIAL   = '"+SE2->E2_FILIAL+"' 
cQuery  += " AND CR_NUM      = '"+cTitulo+"'
cQuery  += " AND CR_TIPO     = 'FN' "
cQuery  += " AND CR_STATUS   = '03' "
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTab,.F.,.T.)

If (cTab)->TEMAPV > 0 

    lRetAPV := .F.

Endif

(cTab)->(DBCloseArea())

Return(lRetAPV)
***************************
Static Function fDelSCRFN()
****************************
Local cQuery    := ""
Local cTab      := GetNextAlias()
Local cTitulo   := ""

cTitulo := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)

cQuery  := " SELECT * FROM "+ RETSQLNAME("SCR") + " A "
cQuery  += " WHERE D_E_L_E_T_ = ''
cQuery  += " AND CR_FILIAL   = '"+SE2->E2_FILIAL+"' 
cQuery  += " AND CR_NUM      = '"+cTitulo+"'
cQuery  += " AND CR_TIPO     = 'FN' "
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTab,.F.,.T.)

If !(cTab)->(EOF()) 

    DBSelectArea("SCR")
    SCR->(DBSetOrder(1))
    While (cTab)->(!EOF())

        If SCR->(DBSeek((cTab)->CR_FILIAL+(cTab)->CR_TIPO+(cTab)->CR_NUM+(cTab)->CR_NIVEL))

            SCR->(RecLock("SCR",.F.))
			    SCR->(dbDelete())
		    SCR->(MsUnLock())
        
        Endif
        (cTab)->(DBSkip())
    
    End

Endif

(cTab)->(DBCloseArea())

Return()
