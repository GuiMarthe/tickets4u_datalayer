SET SEARCH_PATH TO tickets4u;
DROP TRIGGER IF EXISTS trg_atualiza_bilhetes_disponiveis ON compra;
DROP TRIGGER IF EXISTS trg_autoriza_compra ON compra;
DROP TRIGGER IF EXISTS trg_atualiza_disponibilidade_bilhete ON compra;

CREATE OR REPLACE FUNCTION proc_autoriza_compra()
RETURNS TRIGGER AS $$
BEGIN
	IF 0 >= (SELECT bilhetes_disponiveis
			 FROM GRUPO_DE_INGRESSOS g, BILHETE b 
	 	 WHERE b.id_bilhete = new.id_bilhete AND
		       b.id_grupo = g.id_grupo)
		THEN RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_autoriza_compra
BEFORE INSERT ON COMPRA
FOR EACH ROW
EXECUTE PROCEDURE proc_autoriza_compra();

CREATE OR REPLACE FUNCTION proc_atualiza_bilhetes()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE GRUPO_DE_INGRESSOS 
	SET bilhetes_disponiveis = bilhetes_disponiveis - 1 
	WHERE id_grupo = (SELECT id_grupo FROM bilhete where id_bilhete = new.id_bilhete);
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_atualiza_bilhetes_disponiveis
AFTER INSERT ON COMPRA
FOR EACH ROW
EXECUTE PROCEDURE proc_atualiza_bilhetes();

CREATE OR REPLACE FUNCTION proc_atualiza_bilhete()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE bilhete 
	SET disponibilidade = 'False'
	WHERE id_bilhete = new.id_bilhete;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_atualiza_disponibilidade_bilhete
AFTER INSERT ON COMPRA
FOR EACH ROW
EXECUTE PROCEDURE proc_atualiza_bilhete();



