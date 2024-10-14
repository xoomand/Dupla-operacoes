#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#Include "Ap5Mail.Ch"

#Define CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CABA261  บ Autor ณ Marcos Cantalice   บ Data ณ  20/05/23   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Aprova็ใo de Pagamento - Contas M้dicas            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

// User Function fCantalice(cUserApr, cNomeUsu, cMail,cAprov, lCustoMd)
User Function dpowf001(cMail, cChvScr, cNomeUsu, cChvSe2, aSCR, aSE2)
	Local cAssunto   := 'Aprova็ใo de Pagamento'
	Local cURLBrw 	 := AllTrim(GetMv("MV_XWFBRWS")) //IP ou nome do servidor HTTP
	Local cContaWF   := SUPERGETMV("MV_YCONTA", .T., "oliveiramarcos55@hotmail.com") //Conta de e-mail para recebimento da resposta do WF
	Local cImageWF   := SUPERGETMV("MV_XIMGWF", .T., "") //Conta de e-mail para recebimento da resposta do WF
	Local cPrefixo 	 := aSE2[1]
	Local cNumTit	 := IIF(EMPTY(aSE2[2]), aSE2[3], aSE2[3]+" / "+aSE2[2])
	// Local cParc	  	 
	Local cTipo  	 := aSE2[4]
	Local cFornec  	 := aSE2[5]
	Local cCentCus   := aSE2[6]+' - '+POSICIONE("CTT", 1, XFILIAL("CTT")+aSE2[6], "CTT_DESC01")
	Local cValor   	 :=	"R$ "+ Alltrim(Transform(aSE2[7],"@E 999,999,999.99"))
	Local cHist 	 := aSE2[8]
	Local cFilName 	 := FWFilialName()
	Local cTemplat	 := "\html\template_wf_"+cEmpAnt+cFilAnt+".html"
	Local cModel	 := "html\wfaprtit_"+cEmpAnt+cFilAnt+".html"

	ConOut( "dpowf001 enviando email para:",cMail, cChvScr, cNomeUsu, cChvSe2, CenArr2Str(aSCR,";"), CenArr2Str(aSE2,";"))
	oProcess := TWFProcess():New("000001",cAssunto)
	
	oProcess:NewTask(cAssunto, cTemplat)

	//cHtml := StrTran(cHtml,"!Destino!",cDestino)
	oProcess:ohtml:ValByName( "cnome"		, cNomeUsu 	)
	oProcess:oHtml:ValByName( "c_Image" 	, cImageWF	)
	oProcess:oHtml:ValByName( "c_Prefixo" 	, cPrefixo	)
	oProcess:oHtml:ValByName( "c_NumTit" 	, cNumTit	)
	oProcess:oHtml:ValByName( "c_Tipo" 		, cTipo	 	)
	oProcess:oHtml:ValByName( "c_Fornec"	, cFornec 	)
	oProcess:oHtml:ValByName( "c_Centcus" 	, cCentCus  )
	oProcess:oHtml:ValByName( "c_Historico" , cHist		) 
	oProcess:oHtml:ValByName( "c_Valor" 	, cValor    )
	
	aAdd( oProcess:aParams, cChvScr 	)
	aAdd( oProcess:aParams, __cUserId 	) 
	aAdd( oProcess:aParams, cChvSe2 	) 
	aAdd( oProcess:aParams, aSCR 		) 
	aAdd( oProcess:aParams, aSE2 		) 
	
	oProcess:cSubject := cAssunto
	oProcess:cTo := "WF" //cMail

	oProcess:bReturn := "U_dpowf002()"	

	cMailID := oProcess:Start("\workflow\emp"+cEmpAnt+"\wf\")
	
	// **'-----------------------------------------------------------------------------'**
	// **' Inรญcio do bloco de envio de e-mail para o aprovador                         '**
	// **'-----------------------------------------------------------------------------'**
	
	//Carregando nome do arquivo html gerado
    cHtmlFile  := cMailID + ".htm"
    cMailTo    := "mailto:" + cContaWF

	cHtml := wfloadfile("\workflow\emp"+cEmpAnt+"\wf\"+cHtmlFile)
    
	//Substituido o email no corpo do form pelo WFHTTPRET.APL
    cHtml := strtran( cHtml, cMailTo, "WFHTTPRET.APL" )

	//Gerando HTML para ser acessado via Link
    wfsavefile("\workflow\emp"+cEmpAnt+"\wf\"+ cHtmlFile+"l", cHtml)
   
	//Apagando  o arquivo gerado
    fErase("\workflow\emp"+cEmpAnt+"\wf\"+cHtmlFile)

	cHtmlModelo := cModel
	
	oProcess:NewTask(cAssunto, cHtmlModelo)
	FWLogMsg('INFO',, 'SIGAFIN', funName(), '', '01', "(INICIO|WFLINK)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID , 0, 0)

	oProcess:cSubject := cAssunto
	oProcess:cTo := cMail 
	oProcess:ohtml:ValByName("c_Empresa", cFilName)
	oProcess:ohtml:ValByName("c_Image" 	, cImageWF)
	oProcess:ohtml:ValByName("cnome"	, FwGetUserName( __cUserId ) )
	oProcess:ohtml:ValByName("c_AcaoD"	, "incluiu")	
	oProcess:ohtml:ValByName("c_http"	, "http://"+cURLBrw+"/emp"+cEmpAnt+"/wf/" + cMailID + ".html")
	oProcess:Start()
	oProcess:Finish()

Return        
