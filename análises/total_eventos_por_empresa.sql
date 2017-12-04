/* 
 Esta consulta computa o total de eventos cadastrados na plataforma por cnpj 
*/
SELECT 
  cnpj, 
  empresa.nome_fantasia, 
  empresa.tipo_estabelecimento,
  count(*) as total_de_eventos
FROM evento natural left join empresa
group by 1,2,3;
