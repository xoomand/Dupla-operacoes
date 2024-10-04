#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#Include "Ap5Mail.Ch"

User Function dpowf002(oProcess)                                           

	Local aArea 		:= GetArea()
	Local c_Opc     	:= AllTrim(oProcess:oHtml:RetByName("OPC"))
	Local c_Obs     	:= AllTrim(oProcess:oHtml:RetByName("OBS"))
	Local cNiVel		:= 0
	Local c_ChvScr		:= oProcess:aParams[1]
	Local c_User		:= oProcess:aParams[2]
	Local c_ChvSe2		:= oProcess:aParams[3]
	Local a_VetScr		:= oProcess:aParams[4]
	Local a_VetSe2		:= oProcess:aParams[5]
	Local cTabTmp		:= GetNextAlias()

	Private l_Libera 		:= .F.    
	Private l_Niv 			:= .T.
	Private nOpc        	:= If(c_Opc == "S", 2, 4 )
	
	conout("(RETORNO)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
	ConOut( "Testando variaveis " , UsrRetMail(c_User), AllTrim(c_ChvScr), UsrFullName(c_User), c_ChvSe2, a_VetScr[1], CenArr2Str(a_VetSe2, ";"), CenArr2Str(a_VetScr, ";"))
				
	dbSelectArea("SCR")
	dbSetOrder(2)		
	If dbSeek(PadR(c_ChvScr,56) + a_VetScr[6] )
		ConOut( "MaAlcDoc" )
		
		If Empty(Alltrim(c_Obs)) .And. nOpc == 4
			c_Obs := "Titulo não aprovado!"
		Endif 

		l_Libera := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,c_User,SCR->CR_GRUPO,,,,,c_Obs},dDatabase,If(nOpc==2,4,6) ,, @l_Niv)		
		
		ConOut( "Teste liberado: ", l_Libera )
		If nOpc==2
			If !l_Libera
				ConOut( "Liberado Nivel 1" )
				
				cNiVel := cValtoChar(Val(a_VetScr[1]) + 1)
				
				BeginSql Alias cTabTmp					

					SELECT DISTINCT CR_NIVEL,CR_NUM,CR_TIPO,CR_TOTAL,CR_APROV,CR_USER,CR_GRUPO
					FROM %table:SCR% SCR 
					WHERE SCR.%notdel%             
					AND SCR.CR_FILIAL = %Exp:FwxFilial("SCR")%                    
					AND SCR.CR_NUM = %Exp:SCR->CR_NUM%
					AND SCR.CR_DATALIB =  ' '
					AND CAST(SCR.CR_NIVEL AS INT) = %Exp:cNiVel%
					
				EndSql				
			
				ConOut( "Enviando nivel acima" )
				ConOut( UsrRetMail(a_VetScr[6]), AllTrim(c_ChvScr), UsrFullName(a_VetScr[6]), c_ChvSe2, cNiVel, CenArr2Str(a_VetSe2, ";"))
				ConOut(GetLastQuery()[2])
				While !(cTabTmp)->(Eof()) 
					ConOut("Query entrou")
					U_dpowf001(UsrRetMail((cTabTmp)->CR_USER),; 
								AllTrim(c_ChvScr),; 
								UsrFullName((cTabTmp)->CR_USER),; 
								c_ChvSe2,;
								{(cTabTmp)->CR_NIVEL,(cTabTmp)->CR_NUM,(cTabTmp)->CR_TIPO,(cTabTmp)->CR_TOTAL,(cTabTmp)->CR_APROV,(cTabTmp)->CR_USER,(cTabTmp)->CR_GRUPO},;
								a_VetSe2)
				
					(cTabTmp)->(dbSkip())
				End									

				(cTabTmp)->(DbCloseArea())
			Else 
				ConOut( "Liberando Financeiro" )
				dbSelectArea("SE2")
				dbSetOrder(1)
				If DBSeek(FwxFilial("SE2")+c_ChvSe2)
					RecLock("SE2",.F.)
					SE2->E2_DATALIB := dDatabase
					SE2->(MsUnlock())						
				Endif 
				ConOut( "Fim" )
				(cAliasSCR)->(dbSkip())
			Endif 
		Endif 
	Endif
			
	RestArea(aArea)
Return
