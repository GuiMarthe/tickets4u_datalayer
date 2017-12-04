SELECT 
  e.tipo_estabelecimento, 
  count(*) total_de_eventos
FROM evento natural left join empresa as e
GROUP BY 1;
