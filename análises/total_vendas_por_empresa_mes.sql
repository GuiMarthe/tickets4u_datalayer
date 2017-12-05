SELECT 
	empresa.nome_fantasia, 
	date_trunc('month', compra.data_compra) as mes, 
	count(*) as total_vendas
FROM compra 
natural join bilhetes 
natural join GRUPO_DE_INGRESSOS
natural join sessao 
natural join evento
natural join empresa,
group by cube (1,2,3);




