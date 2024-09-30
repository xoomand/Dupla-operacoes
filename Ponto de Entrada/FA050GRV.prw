#INCLUDE "RWMAKE.CH"
//#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA050GRV  ºMarcos Cantalice  ³         º Data ³  15/08/24   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Ponto de Entrada para criacao de alcada e envio para      º±±
±±º          ³  aprovacao via workflow	  		 	 	                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/

User Function FA050GRV()

	Local cAmb      := GetArea()
    Local cTabTmp	:= GetNextAlias()
	Local cGrpApr   := ''
    Local cTipo     := SUPERGETMV("MV_XTPFIN", .T., "FOL")
    
    IF !SE2->E2_TIPO $ cTipo 

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
            // CRIAR GRUPO PARA ALÇADA DE APROVAÇÃO DO FINANCEIRO
            MaAlcDoc({SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),"FN",SE2->E2_VALOR,,,Alltrim(cGrpApr),,SE2->E2_MOEDA,SE2->E2_TXMOEDA,SE2->E2_EMISSAO},,1)
                        
            DbSelectArea("SCR")
            DbsetOrder(1) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
            If DbSeek(xfilial("SCR")+"FN"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))

                While !SCR->(EOF()) .AND. ALLTRIM(xfilial("SCR")+"FN"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)) == ALLTRIM(SCR->(CR_FILIAL+CR_TIPO+CR_NUM))
                    If Alltrim(SCR->CR_NIVEL) $ "01|1"
                        U_dpowf001(UsrRetMail(SCR->CR_USER),; 
                                    ALLTRIM(SCR->(CR_FILIAL+CR_TIPO+CR_NUM)),; 
                                    UsrFullName(SCR->CR_USER),; 
                                    SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),;
                                    {SCR->CR_NIVEL,SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,SCR->CR_USER,SCR->CR_GRUPO},;
                                    {SE2->E2_PREFIXO,SE2->E2_PARCELA,SE2->E2_NUM,SE2->E2_TIPO,SE2->E2_NOMFOR,SE2->E2_CCUSTO,SE2->E2_VALOR,SE2->E2_HIST})
                    Endif 
                    SCR->(DBSKIP())
                End

                MSGINFO("Título enviado para aprovação.","TOTVS")
            Endif 
        Endif 
    Endif 
	
	RestArea(cAmb)

Return 
