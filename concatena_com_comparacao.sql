SELECT name AS [Nome da tabela ML-Completo], DSL_LISTA as Descrição, NOM_LISTA as [Nome no fluig], CONCAT(COD_EMPRESA, FORMAT(COD_LISTA, '000')) as [Nome ML]
FROM SYS.TABLES AS s
JOIN META_LISTA AS m
--Extrai as letras a partir da 5° posição e concatena com empresa+lista
ON CAST(RIGHT(s.name,4) AS INT) = CAST(CONCAT(COD_EMPRESA, FORMAT(COD_LISTA, '000')) AS INT)
WHERE s.name LIKE 'ML%'