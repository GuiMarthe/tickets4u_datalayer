import string 
import datetime
from pprint import pprint
from sqlalchemy import create_engine
import random
from tqdm import tqdm
import pickle

estrutura_aleatoria = {

        'cinema':        {'max_sessoes':5,'max_grupos':2},

        'teatro':        {'max_sessoes':5,'max_grupos':2},
        
        'estadio':       {'max_sessoes':1,'max_grupos':5},

        'casa_de_shows': {'max_sessoes':3,'max_grupos':6}
        
        }


sql_insert_strings = {
    'sessao': '''
    INSERT INTO sessao(id_sessao, id_evento, num_bilhetes, data_hora_inicio, data_hora_fim) Values(
    
    {id_sessao}, {id_evento} , {num_bilhetes}, '{data_hora_inicio}', '{data_hora_fim}'
    
    );\n
    ''',
    'ocorre': '''
    
    INSERT INTO ocorre(nome, id_sessao) values( '{}', {});\n
    
    ''',
    'local':'''
    
    INSERT INTO local(nome, id_local, mapa, logradouro, sala, capacidade) Values(

    '{nome}', {id_local}, '{mapa}', '{logradouro}', '{sala}', {capacidade}
    
    );\n
    ''',
    'grupo':'''
    
    INSERT INTO grupo_de_ingressos(nome, id_sessao, id_grupo, tipo, 
                                   preco, vigencia_compra, tipo_assento, bilhetes_disponiveis) Values(

    '{nome}', {id_sessao}, {id_grupo}, '{tipo}', {preco}, '{vigencia_compra}', '{tipo_assento}', {bilhetes_disponíveis}
    );\n
    ''',
    'bilhete':'''
    
    INSERT INTO bilhete(id_grupo, id_bilhete, posicao_mapa) VALUES(

        {id_grupo}, {id_bilhete}, '{posicao_mapa}' 

    );\n
    
    '''

}


def random_date(start,l):
   current = start
   while l >= 0:
      curr = current + datetime.timedelta(days=random.randrange(60))
      yield curr
      l-=1


def write_random_sessions(sql_file, id_evento, tipo, num_bilhetes, data_inicio):
    '''
    gera sesões de ingressos para cada tipo de evento 
    
    '''
    locais = random.choice('''
                            do_barulho 
                            do_mal 
                            das_amiga 
                            da_patota_loca
                            dos_brother
                            de_saoPaulo
                            da_maldade
                            dos_peixes
                            da_sabedoria
                            da_linhaca
                            da_vergonha_alheia
                          '''.split())
    local_prefix = tipo if tipo!='esporte' else 'estadio'
    global id_sessao
    n_sessoes = random.randint(a=0, 
                               b=estrutura_aleatoria[tipo]['max_sessoes'])

    for data in tqdm(random_date(data_inicio, n_sessoes)):
        ### write session insert into sql file
        sql_insert = sql_insert_strings['sessao'].format(
                id_sessao = id_sessao, 
                id_evento = id_evento, 
                num_bilhetes = num_bilhetes, 
                data_hora_inicio = data.strftime('%Y-%m-%d %H:%M:%S'),
                data_hora_fim = (data + datetime.timedelta(hours=3)).strftime('%Y-%m-%d %H:%M:%S')
               )
        sql_file.write(sql_insert)

        ### write local insert to sql file

        sql_insert_local = sql_insert_strings['local'].format(
                nome=local_prefix + locais.replace('_', ' '),
                id_local=id_sessao, 
                mapa='Setor'+random.choice(string.ascii_uppercase),
                logradouro=random.choice(adr),
                sala='Sala'+random.choice(string.ascii_uppercase),
                capacidade=num_bilhetes
                )
        sql_file.write(sql_insert_local)

        ### write ocorre insert to sql file
        sql_insert_ocorre = sql_insert_strings['ocorre'].format(
                local_prefix + locais.replace('_', ' '),
                id_sessao
                )
        sql_file.write(sql_insert_ocorre)
    
        write_random_tickets_group(sql_file, id_sessao, tipo, num_bilhetes, data)

        id_sessao+=1


def write_random_tickets_group(sql_file, id_sessao, tipo, bilhetes_disponíveis, data_inicio):

    global id_grupo

    numero_de_grupos = random.choice(range(1 , estrutura_aleatoria[tipo]['max_grupos']))
    numero_de_bilhetes_no_grupo = round(bilhetes_disponíveis/numero_de_grupos, 0)

    while numero_de_grupos > 0:
        
        sql_insert_group = sql_insert_strings['grupo'].format(
                
                        nome='Grupo '+random.choice(string.ascii_uppercase)+random.choice(string.ascii_uppercase),
                        id_sessao=id_sessao, 
                        id_grupo=id_grupo, 
                        tipo='Tipo '+random.choice(string.ascii_uppercase),
                        preco=10*(random.uniform(10, 999)//10),
                        vigencia_compra=data_inicio - datetime.timedelta(days=random.randint(2, 30)),
                        tipo_assento='Assento '+random.choice(string.ascii_uppercase),
                        bilhetes_disponíveis=numero_de_bilhetes_no_grupo
                )
        sql_file.write(sql_insert_group)

        write_random_tickets(sql_file, id_grupo, numero_de_bilhetes_no_grupo)

        id_grupo+=1
        numero_de_grupos-=1




def write_random_tickets(sql_file, id_grupo, num_bilhetes):
    global id_bilhete

    while num_bilhetes > 0:
        sql_insert_bilhete = sql_insert_strings['bilhete'].format(
                    id_grupo=id_grupo,
                    id_bilhete=id_bilhete,
                    posicao_mapa=random.choice(string.ascii_uppercase)+
                    ''.join(random.choices(string.digits,k=2)),
                    )

        sql_file.write(sql_insert_bilhete)

        id_bilhete+=1

        num_bilhetes-=1


if __name__ == '__main__':
	
    with open('scripts/list_addr.txt', 'r') as adr_file:
        adr = adr_file.read().split('\n')[-1:]

    con = create_engine(
        'postgresql+psycopg2://guima:aliaskm1d2dww@localhost/tickets4u')
    
    id_sessao = 0
    id_grupo = 0
    id_bilhete = 0

    with open('./população_db/popula_sessao_local.sql', 'w') as sql_file:

        sql_file.write('set search_path to tickets4u;')
    
        tuplas = con.execute('''
			set search_path to tickets4u;
                        select id_evento, 
			       empresa.tipo_estabelecimento, 
			       num_bilhetes, 
			       inicio 
			from evento natural join empresa;
			''').fetchall()
        for tupla in tqdm(tuplas):
            write_random_sessions(sql_file, *tupla)



