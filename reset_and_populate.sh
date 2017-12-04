psql tickets4u -f população_db/drop_db.sql;
psql tickets4u -f população_db/create_db.sql;
psql tickets4u -f população_db/popula_empresa_evento.sql;
psql tickets4u -f população_db/popula_subclasse_eventos.sql;
#todo sessao
#todo local
#todo grupo de ingressos
#todo bilhete 
psql tickets4u -f população_db/popule_clientes.sql;
#todo compra
