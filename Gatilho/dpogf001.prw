#include "PROTHEUS.CH"
#include "TOPCONN.CH"

User Function dpogf001(cCC)
    Local aArea 	:= GetArea()
    Local cTmpQry   := GetNextAlias()
    Local cCCusto   := cCC
    Local cQry      := ""
    Local cTexto    := ""

    cQry := " SELECT DBL_GRUPO, SAL.AL_DESC, SAL.AL_NIVEL, SAK.AK_NOME " + CRLF
    cQry += "     FROM " + RetSqlName("DBL") + " DBL " + CRLF
    cQry += " INNER JOIN " + RetSqlName("SAL") + " SAL	 " + CRLF
    cQry += " 	ON SAL.D_E_L_E_T_ = ' '  " + CRLF
    cQry += " 	AND SAL.AL_FILIAL = DBL.DBL_FILIAL  " + CRLF
    cQry += " 	AND SAL.AL_COD = DBL.DBL_GRUPO " + CRLF
    cQry += " INNER JOIN " + RetSqlName("SAK") + " SAK  " + CRLF
    cQry += " 	ON SAK.D_E_L_E_T_ = ' '  " + CRLF
    cQry += " 	AND SAK.AK_COD = SAL.AL_APROV  " + CRLF
    cQry += " WHERE DBL.D_E_L_E_T_ = ' '  " + CRLF
    cQry += " 	AND DBL.DBL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
    cQry += " 	AND DBL.DBL_CC = '" + cCCusto + "' " + CRLF
    
    If Select(cTmpQry) > 0
        (cTmpQry)->(DbCloseArea())
    Endif 

    cQry 	:= 	ChangeQuery (cQry)

    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry), cTmpQry, .F., .T.)
    
    dbSelectArea(cTmpQry)
    
    If (cTmpQry)->(EOF())
        cTexto := "Grupo de Aprovação não encontrado " + CRLF
        cTexto += " " + CRLF
        cTexto += "Para avançar com este centro de custo é necessario que seja cadastrado a alçada de aprovação para este" + CRLF
        
        nRet := Aviso("Atenção", cTexto, { "Ok" }, 3)

        cCCusto := ""
    Endif

    (cTmpQry)->(DbCloseArea())
    RestArea(aArea)

Return cCCusto
