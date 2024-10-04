#Include "Protheus.ch" 

User Function F050ALT()
    
Local lret      := .T.
Local cNumDoc   := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
Local cGrpApr   := ''
Local cUpdate	:= ''
Local cTabTmp	:= GetNextAlias()

//Verifica se o título já tem aprovador
// lret    := fTemAprov(cNumDoc) 

// If !lret
//     aviso("Atenção","Esse título já teve aprovação por parte de gestores, solicite o estorno da aprovação para poder alterar o título",{"OK"})    
// Else 

cUpdate	:= " UPDATE " + RetSqlName("SCR") +" "
cUpdate	+= " SET D_E_L_E_T_ = '*', 
cUpdate	+= " R_E_C_D_E_L_ = R_E_C_N_O_ 
cUpdate	+= " WHERE CR_NUM  = '"+cNumDoc+"' "
cUpdate += " AND CR_TIPO     = 'FN' "	
cUpdate	+= " AND D_E_L_E_T_ <> '*' "

nRet := TcSqlExec(cUpdate)  
if nRet < 0 
    Alert(Time() +  "Erro: " + TCSQLError() )
endif

BeginSql Alias cTabTmp					

    SELECT DISTINCT 
        DBL_GRUPO
    FROM %table:DBL% DBL
        INNER JOIN %table:SE2% SE2
            ON SE2.%notdel% 
            AND E2_FILIAL =  %Exp:FwxFilial("SE2")%                    
    WHERE DBL.%notdel%             
    AND DBL_FILIAL =  %Exp:FwxFilial("DBL")%             
    AND DBL_CC = %Exp:SE2->E2_CCUSTO%
EndSql				

If !(cTabTmp)->(Eof())
    
    cGrpApr := (cTabTmp)->DBL_GRUPO

EndIf

(cTabTmp)->(DbCloseArea())

If !Empty(cGrpApr)
    
    MaAlcDoc({cNumDoc,"FN",SE2->E2_VALOR,,,Alltrim(cGrpApr),,SE2->E2_MOEDA,SE2->E2_TXMOEDA,SE2->E2_EMISSAO},,1)

    DbSelectArea("SCR")
    DbsetOrder(1) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
    If DbSeek(xfilial("SCR")+"FN"+cNumDoc)

        While !SCR->(EOF()) .AND. ALLTRIM(xfilial("SCR")+"FN"+cNumDoc) == ALLTRIM(SCR->(CR_FILIAL+CR_TIPO+CR_NUM))
            If Alltrim(SCR->CR_NIVEL) $ "01|1"
                U_dpowf001(UsrRetMail(SCR->CR_USER),; 
                            ALLTRIM(SCR->(CR_FILIAL+CR_TIPO+CR_NUM)),; 
                            UsrFullName(SCR->CR_USER),; 
                            cNumDoc,;
                            {SCR->CR_NIVEL,SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,SCR->CR_USER,SCR->CR_GRUPO},;
                            {SE2->E2_PREFIXO,SE2->E2_PARCELA,SE2->E2_NUM,SE2->E2_TIPO,SE2->E2_NOMFOR,SE2->E2_CCUSTO,SE2->E2_VALOR,SE2->E2_HIST})
            Endif 
            SCR->(DBSKIP())
        End

        MSGINFO("Título RE-enviado para aprovação.","TOTVS")
    Endif 

Endif 

// Endif 
    
Return (lret)

***************************
Static Function fTemAprov(cTitulo)
****************************
Local cQuery    := ""
Local cTab      := GetNextAlias()
Local lRetAPV   := .T.

cQuery  := " SELECT count(*) AS TEMAPV FROM "+ RETSQLNAME("SCR") + " A "
cQuery  += " WHERE D_E_L_E_T_ = ''
cQuery  += " AND CR_FILIAL   = '"+SE2->E2_FILIAL+"' 
cQuery  += " AND CR_NUM      = '"+cTitulo+"'
cQuery  += " AND CR_TIPO     = 'FN' "
cQuery  += " AND CR_STATUS   = '03' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTab,.F.,.T.)

If (cTab)->TEMAPV > 0 

    lRetAPV := .F.

Endif

(cTab)->(DBCloseArea())

Return(lRetAPV)
