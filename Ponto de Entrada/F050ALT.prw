#Include "Protheus.ch" 

User Function F050ALT()
    
    DbSelectArea("SCR")
    DbsetOrder(1) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
    IF DbSeek(xfilial("SCR")+ALLTRIM(SE2->E2_TIPO)+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
        WHILE SCR->(!EOF()) .AND. ALLTRIM(SCR->(CR_FILIAL+CR_TIPO+CR_NUM)) == ALLTRIM(xfilial("SCR")+ALLTRIM(SE2->E2_TIPO)+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
            SCR->(RecLock("SCR",.F.))
                SCR->(DbDelete())
            SCR->(MsUnlock())

            SCR->(DBSKIP())
            // MaAlcDoc({M->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),M->E2_TIPO,M->E2_VALOR   ,,,"000001"    ,,1                                      ,               ,/*dDatabase*/      },dDatabase         ,3 ,, /*@l_Niv*/)
        END
    ENDIF

    MaAlcDoc({SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),SE2->E2_TIPO,SE2->E2_VALOR   ,,,"000001"    ,,1                                      ,               ,/*dDatabase*/      },dDatabase         ,1 ,, /*@l_Niv*/)
    
Return (.T.)
