set search_path to tickets4u;

ALTER TABLE sessao DROP CONSTRAINT sessao_id_evento_key;

ALTER TABLE bilhete ALTER COLUMN disponibilidade SET DEFAULT TRUE;

