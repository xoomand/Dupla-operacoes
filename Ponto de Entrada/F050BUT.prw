#Include "Protheus.ch"

*---------------------*
User Function F050BUT()
*---------------------*
Local aAreaAnt	:= GetArea()          
Local aBotao 	:= {}                     

aAdd( aBotao, { "BUDGET", { || U_dpoaf002( SE2->( RecNo() ),SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))  }, "Visualizar Aprovação", "Visualizar Aprovação" } )
    

RestArea( aAreaAnt )                                                

Return aBotao
