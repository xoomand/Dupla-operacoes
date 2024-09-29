#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include "Topconn.ch"

#DEFINE CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} F050ROT
                                                            
@project Aprova��o de Titulo
@description Ponto de entrada respons�vel por incluir um novo Item no menu padr�o FINA050
@author Marcos Cantalice
@since 13/07/2024
@version 1.0		
/*/
 
User Function F050ROT()
     
    // Local aArea   := GetArea()
    Local aRotina := ParamIXB // Array contendo os botoes padr�es da rotina.
 
    // Tratamento no array aRotina para adicionar novos botoes e retorno do novo array.
    // Aadd(aRotina, { "Enviar p/ Aprova��o", "U_ENVAPROV", 0, 8, 0,.F.})
    Aadd(aRotina, { "Visualizar Aprova��o","U_dpoaf002( SE2->( RecNo() ),SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )", 0, 2, 0,Nil})
     
    // RestArea(aArea)
 
Return aRotina
 
