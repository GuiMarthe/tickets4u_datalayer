WITH valor_dos_bilhetes as (
    SELECT bilhete.id_bilhete, grupo_de_ingressos.preco as preco_venda 
    FROM bilhete natural left join grupo_de_ingressos 
)
SELECT 
    cliente.email, 
    count(*) as n_bilhetes,
    sum(preco_venda) as valor_bilhetes
FROM compras
left join valor_dos_bilhetes v on v.id_bilhete = compras.id_bilhete
NATURAL JOIN cliente
group by clientes.email
where compras.data_compra > CURRENT_DATE - INTERVAL '2 months'
ORDER BY valor_bilhetes;

