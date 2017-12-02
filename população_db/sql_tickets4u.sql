CREATE TABLE EMPRESA (
	CNPJ	INTEGER PRIMARY KEY,
	nome_fantasia	VARCHAR(100) NOT NULL UNIQUE,
	localizacao	VARCHAR(100),
	telefone	VARCHAR(12),
	tipo_estabelecimento	VARCHAR(100)
);

CREATE TABLE CLIENTE (
	CPF	INTEGER PRIMARY KEY,
	login	VARCHAR(20) UNIQUE,
	senha	VARCHAR(20),
	nome	VARCHAR(50),
	email	VARCHAR(20)
);

CREATE TABLE LOCAL (
	nome	VARCHAR(30) UNIQUE NOT NULL,
	id_local	INTEGER PRIMARY KEY,
	mapa	VARCHAR(30),
	logradouro	VARCHAR(30) NOT NULL,
	sala	VARCHAR(10),
	capacidade	INTEGER
);

CREATE TABLE EVENTO (
	CNPJ INTEGER UNIQUE NOT NULL,
	-- a exclusão do cnpj de uma empresa será bloqueada, mas 
	-- a alteração será propagada
	FOREIGN KEY(CNPJ) REFERENCES EMPRESA(CNPJ)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	id_evento	INTEGER PRIMARY KEY,
	regulamento	VARCHAR(100),
	descricao	VARCHAR(100),
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
	titulo	VARCHAR(30) NOT NULL,
	sinopse	VARCHAR(30) NOT NULL,
	genero	VARCHAR(10),
	dub	BOOLEAN,
	duracao	VARCHAR(10),
	direcao	VARCHAR(30),
	distribuicao	VARCHAR(30),
	tipo_exibicao	VARCHAR(30),
	produtora	VARCHAR(30)
);

CREATE TABLE PECA_TEATRO (
	id_evento INTEGER  NOT NULL,
	-- se o evento for alterado, ou excluído, os dados de sua 
	-- subclasse deverão ser aleterados/excluídos também
	FOREIGN KEY(id_evento) REFERENCES EVENTO(id_evento)
		ON DELETE CASCADE ON UPDATE CASCADE,
	titulo	VARCHAR(30) NOT NULL,
	descricao	VARCHAR(30) NOT NULL,
	genero	VARCHAR(10),
	dub	BOOLEAN,
	duracao	VARCHAR (10),
	direcao	VARCHAR(30)
);

CREATE TABLE SHOW (
	id_evento INTEGER  NOT NULL, 
	-- se o evento for alterado, ou excluído, os dados de sua 
	-- subclasse deverão ser aleterados/excluídos também
	FOREIGN KEY(id_evento) REFERENCES EVENTO(id_evento)
		ON DELETE CASCADE ON UPDATE CASCADE,
	artista	VARCHAR(30) NOT NULL,
	genero	VARCHAR(10),
	local	VARCHAR(30)
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
	data_hora_fim	TIMESTAMP NOT NULL,
	CHECK (data_hora_inicio < data_hora_fim)

);


CREATE TABLE OCORRE (
	nome VARCHAR(30), 
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
	nome VARCHAR(30), 
	id_sessao INTEGER UNIQUE NOT NULL, 
	-- mudanças na sessão são inteiramente propagadas
	FOREIGN KEY(id_sessao) REFERENCES SESSAO(id_sessao)
		ON DELETE CASCADE ON UPDATE CASCADE,
	id_grupo INTEGER PRIMARY KEY, 
	tipo	VARCHAR(30) NOT NULL,
	vigencia_compra	DATE NOT NULL,
	tipo_assento	VARCHAR(20),
	bilhetes_disponiveis	INTEGER NOT NULL
);

CREATE TABLE BILHETE (
	CNPJ INTEGER UNIQUE  NOT NULL,
	id_grupo  INTEGER UNIQUE  NOT NULL,
	-- mudanças nos grupos de ingressos são inteiramente propagadas
	FOREIGN KEY(id_grupo) REFERENCES GRUPO_DE_INGRESSOS(id_grupo)
		ON DELETE CASCADE ON UPDATE CASCADE,
	id_bilhete	INTEGER PRIMARY KEY,
	posicao_mapa	VARCHAR(30) NOT NULL,
	preco	DECIMAL(10,2) NOT NULL,
	promocao	BOOLEAN,
	disponibilidade	BOOLEAN
);

CREATE TABLE COMPRA (
	tipo_desconto VARCHAR(30),
	data_compra TIMESTAMP,
	forma_de_pagto VARCHAR(30),
	cpf_comprador INTEGER,
	id_bilhete INTEGER,
	FOREIGN KEY (cpf_comprador) references CLIENTE(CPF)
		ON DELETE RESTRICT  ON UPDATE RESTRICT,
	FOREIGN KEY (id_bilhete) REFERENCES BILHETE(id_bilhete)
		ON DELETE RESTRICT  ON UPDATE RESTRICT
);
