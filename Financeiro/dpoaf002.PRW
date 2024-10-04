#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#Include "Ap5Mail.Ch"


User Function dpoaf002(nReg,cNumDoc)

	Local aArea		:= GetArea()
	Local cAliasSCR := GetNextAlias()	
	Local cSituaca  := ""
	Local cStatus   := ""
	
	Local cTitDoc   := "T�tulo:"
	Local cAddHeader:= ""

	Local lBloq     := .F.
	Local lQuery    := .F.
	
	Local nX   		:= 0
	Local nY        := 0

	Local oDlg
	Local oGet
	Local oBold
	Local cQuery   := ""
	Local aStruSCR := {}

	Local N       := 1
	Private aCols   := {}
	Private aHeader := {}

	If !Empty(cNumDoc) 

		aHeader:= {}
		aCols  := {}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄż
		//ł Faz a montagem do aHeader com os campos fixos.               ł
		//ŔÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŮ
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("SCR")
		While !Eof() .And. (SX3->X3_ARQUIVO == "SCR")
			IF AllTrim(X3_CAMPO)$"CR_YOBS2/CR_NIVEL/CR_OBS/CR_DATALIB/" + cAddHeader
				AADD(aHeader,{	TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )

				If AllTrim(x3_campo) == "CR_NIVEL"
					AADD(aHeader,{ OemToAnsi("Usuario"),"bCR_NOME",   "",15,0,"","","C","",""} )
					AADD(aHeader,{ OemToAnsi("Situacao"),"bCR_SITUACA","",20,0,"","","C","",""} ) 
					AADD(aHeader,{ OemToAnsi("Usuario Lib."),"bCR_NOMELIB","",15,0,"","","C","",""} ) 
				EndIf

			Endif

			dbSelectArea("SX3")		
			dbSkip()
		EndDo

		ADHeadRec("SCR",aHeader)

		aStruSCR := SCR->(dbStruct())

		cQuery    := "SELECT SCR.*, SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
		cQuery    += "SCR.CR_NUM = '"+cNumDoc+"' AND "
		cQuery    += "SCR.CR_TIPO = 'FN' AND "
		cQuery    += "SCR.D_E_L_E_T_=' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

		For nX := 1 To Len(aStruSCR)
			If aStruSCR[nX][2]<>"C"
				TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
			EndIf
		Next nX

		dbSelectArea(cAliasSCR)

		While !Eof() .And. ALLTRIM((cAliasSCR)->CR_FILIAL+(cAliasSCR)->CR_TIPO+(cAliasSCR)->CR_NUM) == ALLTRIM(xFilial("SCR") + 'FN' + cNumDoc)
				
			dbselectarea("SCR")
			dbGoto((cAliasSCR)->SCRRECNO)
		
			aadd(aCols,Array(Len(aHeader)+1))
			nY++
			For nX := 1 to Len(aHeader)
				If IsHeadRec(aHeader[nX][2])
					aCols[nY][nX] := IIf(lQuery , (cAliasSCR)->SCRRECNO , SCR->(Recno())  )
				ElseIf IsHeadAlias(aHeader[nX][2])
					aCols[nY][nX] := "SCR"
				ElseIf aHeader[nX][02] == "bCR_NOME"
					aCols[nY][nX] := UsrFullName((cAliasSCR)->CR_USER)
				ElseIf aHeader[nX][02] == "bCR_SITUACA"
					Do Case
					Case (cAliasSCR)->CR_STATUS == "01"
						cSituaca := "Aguardando"						
					Case (cAliasSCR)->CR_STATUS == "02"
						cSituaca := "Em Aprovacao"						
					Case (cAliasSCR)->CR_STATUS == "03"
						cSituaca := "Aprovado" 
					Case (cAliasSCR)->CR_STATUS == "04"
						cSituaca := "Bloqueado"                
						lBloq := .T. 
					Case (cAliasSCR)->CR_STATUS == "05"
						cSituaca := "Nivel Liberado "						
					EndCase
					aCols[nY][nX] := cSituaca					
				ElseIf aHeader[nX][02] == "bCR_NOMELIB"
					aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USERLIB)
				ElseIf ( aHeader[nX][10] != "V")
					aCols[nY][nX] := FieldGet(FieldPos(aHeader[nX][2]))
				EndIf
				
			Next nX
			aCols[nY][Len(aHeader)+1] := .F.
			
			dbSelectArea(cAliasSCR)
			dbSkip()
		EndDo

		If !Empty(aCols)
			If lBloq 
				cStatus := 'BLOQUEADO'
			Else 
				cStatus := cSituaca
			Endif 
			n:=	 IIF(n > Len(aCols), Len(aCols), n)  
			DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			DEFINE MSDIALOG oDlg TITLE OemToAnsi("APROVA��O CONTAS A PAGAR") From 109,095 To 400,600 OF oMainWnd PIXEL	 
			@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 120,009 OF oDlg FONT oBold
				
			@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009 
			@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
			@ 132,205 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  
			oGet:= MSGetDados():New(038,003,120,250,2,,,"")
			oGet:Refresh()
			@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL	
			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			Aviso("Atencao","Este processo nao possui controle de aprovacao.", {"Ok"}) 
		EndIf

		dbSelectArea(cAliasSCR)
		dbCloseArea()

	Else
		Aviso("Atencao","Este Documento nao possui controle de aprovacao.", {"Ok"})
	EndIf

	RestArea(aArea)

Return 
