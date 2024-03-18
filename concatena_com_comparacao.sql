SELECT name, DSL_LISTA, NOM_LISTA, COD_EMPRESA, COD_LISTA
FROM SYS.TABLES AS s
JOIN META_LISTA AS m
--Extrai as letras a partir da 5° posição e concatena com empresa+lista
ON SUBSTRING(s.name, 5, LEN(s.name)) = CONCAT(m.COD_EMPRESA, m.COD_LISTA)
WHERE s.name LIKE 'ML00%'