psql tickets4u -f população_db/drop_db.sql;
psql tickets4u -f população_db/create_db.sql;
psql tickets4u -f população_db/triggers.sql;
psql tickets4u -f população_db/popula_empresa_evento.sql;
psql tickets4u -f população_db/update_num_bilhetes.sql;
psql tickets4u -f população_db/update_schema.sql;
psql tickets4u -f população_db/popula_subclasse_eventos.sql;
psql tickets4u -f população_db/popula_sessao_local.sql;
psql tickets4u -f população_db/popule_clientes.sql;
