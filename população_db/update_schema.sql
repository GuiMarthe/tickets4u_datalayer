set search_path to tickets4u;

ALTER TABLE sessao DROP CONSTRAINT sessao_id_evento_key;

ALTER TABLE bilhete ALTER COLUMN disponibilidade SET DEFAULT TRUE;

ALTER TABLE local DROP CONSTRAINT local_nome_key;

ALTER TABLE grupo_de_ingressos DROP CONSTRAINT grupo_de_ingressos_id_sessao_key;

ALTER TABLE bilhete DROP CONSTRAINT bilhete_id_grupo_key;

