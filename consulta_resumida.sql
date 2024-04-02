DECLARE @Os NVARCHAR(50) = '3.07872.32.001' 
     DECLARE @plano nvarchar(50) = 'CNC008956' 
     DECLARE @resultado VARCHAR(MAX); 
     with CTE AS ( 
         SELECT  NSEQPLANOCORTE,
         ZP.QUANTIDADE,
         KO.CODCCUSTO,
         ZP.CODORDEM,
         ZEX.NUMDESENHO,
         ZEX.DESCRICAO,
         ZEX.POSICAODESENHO,CAST(ZEX.BITOLA AS VARCHAR) + ' x ' + CAST(ZEX.COMPRIMENTO AS VARCHAR) + ' x ' + CAST(ZEX.LARGURA AS VARCHAR) AS DIMENSOES,
         KAT.CODATIVIDADE,
         ZP.NUMPLANOCORTE,
         KAV.DSCATIVIDADE,	 
                               (   SELECT STUFF((  
                                          SELECT ', ' + Z2.DESCATIVIDADE  
                                          FROM FLUIG.dbo.Z_CRM_EX001021 AS Z2  
                                          INNER JOIN FLUIG.dbo.ESTOQUECD AS E2 ON Z2.OSPROCESSO = E2.OS COLLATE SQL_Latin1_General_CP1_CI_AI  
                                          INNER JOIN FLUIG.dbo.Z_CRM_EX001005 AS ZZ2 ON ZZ2.OS = Z2.OSPROCESSO AND ZZ2.IDCRIACAO = Z2.IDCRIACAOPROCESSO  
                                          INNER JOIN FLUIG.dbo.Z_CRM_EX001005COMPL AS ZCM2 ON ZCM2.OS = ZZ2.OS AND ZCM2.CODFILIAL = ZZ2.CODFILIAL   
                                              AND ZCM2.CODCOLIGADA = ZZ2.CODCOLIGADA AND Z2.EXECUCAO = ZCM2.EXECUCAO AND ZZ2.EXECUCAO = ZCM2.EXECUCAO   
                                              AND ZCM2.IDCRIACAO = Z2.IDCRIACAOPROCESSO AND ZCM2.CODORDEM = E2.ORDEM COLLATE SQL_Latin1_General_CP1_CI_AI  
                                          INNER JOIN CORPORE.dbo.KATIVIDADE AS KAT2 ON KAT2.CODATIVIDADE = E2.ATIVIDADE COLLATE SQL_Latin1_General_CP1_CI_AI   
                                              AND KAT2.CODCOLIGADA = ZZ2.CODCOLIGADA AND KAT2.CODFILIAL = ZZ2.CODFILIAL  
                                          WHERE Z2.OSPROCESSO = @Os  
                                              AND ZZ2.NUMDESENHO = ZEX.NUMDESENHO  
                                              AND ZCM2.CODORDEM = ZP.CODORDEM COLLATE SQL_Latin1_General_CP1_CI_AI  
                                          FOR XML PATH('')), 1, 1, '')  
                              ) AS DESCATIVIDADES, 
                              Z.FORNPARA AS FORNECER, 
                              Z.PRIORIDADE, 
                              RANK() OVER(PARTITION BY NSEQPLANOCORTE ORDER BY Z.PRIORIDADE DESC) as RK 
                         FROM KITEMORDEM AS KO  
                        INNER JOIN  ZMDPLANOAPROVEITAMENTOCORTE  AS ZP ON     
                        ZP.CODCOLIGADA=KO.CODCOLIGADA AND   
                        ZP.CODFILIAL=KO.CODFILIAL AND   
                        ZP.CODORDEM=KO.CODORDEM    
                         INNER JOIN KORDEM AS KOR ON  
                         ZP.CODCOLIGADA = KOR.CODCOLIGADA  
                         AND ZP.CODFILIAL = KOR.CODFILIAL  
                         AND ZP.CODORDEM = KOR.CODORDEM  
                         INNER JOIN KORDEMCOMPL AS KPL ON  
                         ZP.CODCOLIGADA = KPL.CODCOLIGADA  
                         AND ZP.CODFILIAL = KPL.CODFILIAL  
                         AND ZP.CODORDEM = KPL.CODORDEM  
                         INNER JOIN FLUIG.dbo.Z_CRM_EX001005 AS ZEX ON  
                         ZP.CODCOLIGADA =  ZEX.CODCOLIGADA  
                         AND ZP.CODFILIAL = ZEX.CODFILIAL  
                         AND KO.CODESTRUTURA =  ZEX.CODIGOPRD COLLATE SQL_Latin1_General_CP1_CI_AI  
                         AND KO.CODCCUSTO = ZEX.OS COLLATE SQL_Latin1_General_CP1_CI_AI  
                         AND KPL.NUMEXEC = ZEX.EXECUCAO  
                         INNER JOIN KATVORDEM AS KAT ON   
                         ZP.CODCOLIGADA=KAT.CODCOLIGADA AND   
                        ZP.CODFILIAL=KAT.CODFILIAL AND   
                        ZP.CODORDEM=KAT.CODORDEM AND  
                         ZP.CODESTRUTURA=KAT.CODESTRUTURA AND  
                         ZP.CODATIVIDADE=KAT.CODATIVIDADE AND   
                         KO.CODMODELO=KAT.CODMODELO  
                         INNER JOIN KATIVIDADE AS KAV ON  
                         ZP.CODCOLIGADA=KAV.CODCOLIGADA AND   
                        ZP.CODFILIAL=KAV.CODFILIAL AND   
                        KAT.CODATIVIDADE = KAV.CODATIVIDADE  
                        inner join FLUIG.dbo.Z_CRM_EX001021 z on   
                        z.OSPROCESSO = ko.CODCCUSTO COLLATE SQL_Latin1_General_CP1_CI_AI  
                        and z.EXECUCAO = zex.EXECUCAO 
                        and z.IDCRIACAOPROCESSO  = zex.IDCRIACAO 
                        INNER JOIN FLUIG.dbo.Z_CRM_EX001005COMPL ZL ON ZL.OS = Z.OSPROCESSO 
                        AND ZL.CODCOLIGADA = KO.CODCOLIGADA 
                        AND ZL.CODFILIAL = KO.CODFILIAL 
                        AND ZL.CODORDEM = KO.CODORDEM 
                        WHERE   
                       KO.CODCCUSTO =@Os
                       AND ZP.CODFILIAL= 7 
                       AND ZP.CODCOLIGADA = 1
                       AND ZP.NUMPLANOCORTE = @plano
     )SELECT  
     CONCAT('Nome: ',NUMDESENHO COLLATE SQL_Latin1_General_CP1_CI_AI,'_POS. ',CAST(POSICAODESENHO AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CI_AI,CHAR(13) + CHAR(10),' Quantidade: ',CAST(QUANTIDADE as varchar) ) as DETALHES, 
     CONCAT('Tamanho: ',CAST(DIMENSOES as varchar) COLLATE SQL_Latin1_General_CP1_CI_AI,' mm', CHAR(13) + CHAR(10), 'Fornecer para: ', CAST(FORNECER as varchar) COLLATE SQL_Latin1_General_CP1_CI_AI) as EXTRAS,DESCATIVIDADES AS ATIVIDADES 
     FROM CTE WHERE RK = 1