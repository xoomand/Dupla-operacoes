#INCLUDE 'PROTHEUS.CH'
/*/{Protheus.doc} User Function MTALCPER//
    O ponto de entrada MTALCPER permite utilizar o controle de alçadas de forma customizada em documentos que não controlam alçada por padrão. 
    @type  Function
    @author André Luis de Oliveira
    @since 06/11/2021
    @version 1.0
    /*/
User function MTALCPER()

Local aAlc := {}

// Validações do usuário
If SCR->CR_TIPO == 'FN'
    bVisual := {|| cCadastro := "Contas a Pagar", axVisual("SE2", SE2->(RecNo()), 2)}
    aAdd(aAlc,{ SCR->CR_TIPO, 'SE2', 1, 'SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA',bVisual,{|| .T.},{'SE2->E2_DATALIB',CtoD("  /  /  "),dDataBase,CtoD("  /  /  ")}})
EndIf                                   

Return(aAlc)
