#INCLUDE 'PROTHEUS.CH'
/*/{Protheus.doc} User Function MTALCPER//
    O ponto de entrada MTALCPER permite utilizar o controle de al�adas de forma customizada em documentos que n�o controlam al�ada por padr�o. 
    @type  Function
    @author Andr� Luis de Oliveira
    @since 06/11/2021
    @version 1.0
    /*/
User function MTALCPER()

Local aAlc := {}

// Valida��es do usu�rio
If SCR->CR_TIPO == 'FN'
    bVisual := {|| cCadastro := "Contas a Pagar", axVisual("SE2", SE2->(RecNo()), 2)}
    aAdd(aAlc,{ SCR->CR_TIPO, 'SE2', 1, 'SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA',bVisual,{|| .T.},{'SE2->E2_DATALIB',CtoD("  /  /  "),dDataBase,CtoD("  /  /  ")}})
EndIf                                   

Return(aAlc)
