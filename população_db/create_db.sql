CREATE schema tickets4u;
SET search_path to tickets4u;

CREATE TABLE EMPRESA (
	CNPJ	NUMERIC(14) PRIMARY KEY,
	nome_fantasia	VARCHAR(2000) NOT NULL UNIQUE,
	localizacao	VARCHAR(2000),
	telefone	VARCHAR(20),
	tipo_estabelecimento	VARCHAR(2000)
);

CREATE TABLE CLIENTE (
	CPF	NUMERIC(11) PRIMARY KEY,
	login	VARCHAR(2000) UNIQUE,
	senha	VARCHAR(2000),
	nome	VARCHAR(2000),
	email	VARCHAR(2000)
);

CREATE TABLE LOCAL (
	nome	VARCHAR(200) UNIQUE NOT NULL,
	id_local	INTEGER PRIMARY KEY,
	mapa	VARCHAR(200),
	logradouro	VARCHAR(200) NOT NULL,
	sala	VARCHAR(200),
	capacidade	INTEGER
);

CREATE TABLE EVENTO (
	CNPJ	NUMERIC(14),
	-- a exclusão do cnpj de uma empresa será bloqueada, mas 
	-- a alteração será propagada
	FOREIGN KEY(CNPJ) REFERENCES EMPRESA(CNPJ)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	id_evento	INTEGER PRIMARY KEY,
	regulamento	VARCHAR(2000),
	descricao	VARCHAR(2000),
	num_bilhetes	INTEGER NOT NULL,
	classificacao_indicativa	VARCHAR(20) NOT NULL,
	inicio	TIMESTAMP,
	fim	TIMESTAMP 
);

CREATE TABLE FILME (
	id_evento INTEGER  NOT NULL,
	-- se o evento for alterado, ou excluído, os dados de sua 
	-- subclasse deverão ser aleterados/excluídos também
	FOREIGN KEY(id_evento) REFERENCES EVENTO(id_evento)
		ON DELETE CASCADE ON UPDATE CASCADE,
	titulo	varchar(200) not NULL,
	sinopse	varchar(800) not NULL,
	genero	varchar(200),
	dub	boolean,
	duracao	varchar(200),
	direcao	varchar(200),
	distribuicao	varchar(200),
	tipo_exibicao	varchar(200),
	produtora	varchar(200)
);

CREATE TABLE PECA_TEATRO (
	id_evento INTEGER  NOT NULL,
	-- se o evento for alterado, ou excluído, os dados de sua 
	-- subclasse deverão ser aleterados/excluídos também
	FOREIGN KEY(id_evento) REFERENCES EVENTO(id_evento)
		ON DELETE CASCADE ON UPDATE CASCADE,
	titulo	VARCHAR(200) NOT NULL,
	descricao	VARCHAR(800) NOT NULL,
	genero	VARCHAR(200),
	dub	BOOLEAN,
	duracao	VARCHAR (200),
	direcao	VARCHAR(200)
);

CREATE TABLE SHOW (
	id_evento INTEGER  NOT NULL, 
	-- se o evento for alterado, ou excluído, os dados de sua 
	-- subclasse deverão ser aleterados/excluídos também
	FOREIGN KEY(id_evento) REFERENCES EVENTO(id_evento)
		ON DELETE CASCADE ON UPDATE CASCADE,
	artista	VARCHAR(200) NOT NULL,
	genero	VARCHAR(2000),
	local	VARCHAR(200)
);

CREATE TABLE ESPORTE (
	id_evento INTEGER  NOT NULL, 
	-- se o evento for alterado, ou excluído, os dados de sua 
	-- subclasse deverão ser aleterados/excluídos também
	FOREIGN KEY(id_evento) REFERENCES EVENTO(id_evento)
		ON DELETE CASCADE ON UPDATE CASCADE,
	tipo_esporte	VARCHAR(20) NOT NULL,
	competidores	VARCHAR(50) NOT NULL
);

CREATE TABLE SESSAO (
	id_evento INTEGER UNIQUE NOT NULL, 
	-- se o evento for deletado, suas sessões serão mantidas com o id null
	-- e uma lateração será propagada
	FOREIGN KEY(id_evento) REFERENCES EVENTO(id_evento)
		ON DELETE SET NULL  ON UPDATE CASCADE,
	id_sessao	INTEGER PRIMARY KEY,  
	num_bilhetes	INTEGER NOT NULL CHECK (num_bilhetes > 0),
	data_hora_inicio TIMESTAMP NOT NULL,
	data_hora_fim	TIMESTAMP,
	CHECK (data_hora_inicio < data_hora_fim)

);


CREATE TABLE OCORRE (
	nome VARCHAR(200), 
	id_local INTEGER,
	id_sessao INTEGER UNIQUE NOT NULL, 
	-- se um local é deletado, então mantemos as ocorrências porêm com um local null
	-- atualizações deverão ser recriadas para um novo local
	FOREIGN KEY(id_local) REFERENCES LOCAL(id_local)
		ON DELETE SET NULL ON UPDATE RESTRICT,
	-- mudanças na sessão são inteiramente propagadas
	FOREIGN KEY(id_sessao) REFERENCES SESSAO(id_sessao)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE GRUPO_DE_INGRESSOS (
	nome VARCHAR(200), 
	id_sessao INTEGER UNIQUE NOT NULL, 
	-- mudanças na sessão são inteiramente propagadas
	FOREIGN KEY(id_sessao) REFERENCES SESSAO(id_sessao)
		ON DELETE CASCADE ON UPDATE CASCADE,
	id_grupo INTEGER PRIMARY KEY, 
	tipo	VARCHAR(200) NOT NULL,
	preco	DECIMAL(1000,2) NOT NULL,
	vigencia_compra	DATE NOT NULL,
	tipo_assento	VARCHAR(20),
	bilhetes_disponiveis	INTEGER NOT NULL
);

CREATE TABLE BILHETE (
	id_grupo  INTEGER UNIQUE  NOT NULL,
	-- mudanças nos grupos de ingressos são inteiramente propagadas
	FOREIGN KEY(id_grupo) REFERENCES GRUPO_DE_INGRESSOS(id_grupo)
		ON DELETE CASCADE ON UPDATE CASCADE,
	id_bilhete	INTEGER PRIMARY KEY,
	posicao_mapa	VARCHAR(200) NOT NULL,
	disponibilidade	BOOLEAN 
);

CREATE TABLE COMPRA (
	tipo_desconto VARCHAR(200),
	data_compra TIMESTAMP,
	forma_de_pagto VARCHAR(200),
	cpf_comprador INTEGER,
	id_bilhete INTEGER,
	FOREIGN KEY (cpf_comprador) references CLIENTE(CPF)
		ON DELETE RESTRICT  ON UPDATE RESTRICT,
	FOREIGN KEY (id_bilhete) REFERENCES BILHETE(id_bilhete)
		ON DELETE RESTRICT  ON UPDATE RESTRICT
);
