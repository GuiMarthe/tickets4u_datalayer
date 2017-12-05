import datetime
from pprint import pprint
from sqlalchemy import create_engine
import random
from tqdm import tqdm
import pickle

estrutura_aleatoria = {

        'cinema':  {'max_sessoes':15,},

        'teatro':  {'max_sessoes':15,},
        
        'estadio': {'max_sessoes':1, },

        'casa_de_shows': {'max_sessoes':3, }
        
        }


sql_insert_strings = {
    'sessao': '''
    INSERT INTO sessao(id_sessao, id_evento, num_bilhetes, data_hora_inicio, data_hora_fim) Values(
    
    {id_sessao}, {id_evento} , {num_bilhetes}, '{data_hora_inicio}', '{data_hora_fim}'
    
    );\n
    ''',
    'local': '''
    
    INSERT INTO ocorre(nome, id_sessao) values( '{}', {});\n
    
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
    gera sesões de ingressos para cada tipo de evento com as seguintes caracteristicas:
    
    Cinemas entre 30 e 100 lugares (variando em termos de dezenas) e podem ter de 10 a 20 sessões
    criadas para o futuro.
    
    Esportes são eventos únicos com ingressos entre 10000 e 60000 em termos de milhares.

    Shows são eventos que podem de repetir entre 1 a 3 vezes e tem publicos na casa das centenas
    ou milhares, aleatoriamente.

    Pecas de teatros tem a mesma estrutura que cinemas.
    '''
    locais = random.choice('''
                            do_barulho 
                            do_mal 
                            das_amiga 
                            da_patota_loca
                            dos_brother
                            de_saoPaulo
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
                data_hora_inicio = data_inicio.strftime('%Y-%m-%d %H:%M:%S'),
                data_hora_fim = (data_inicio + datetime.timedelta(hours=3)).strftime('%Y-%m-%d %H:%M:%S')
               )
        sql_file.write(sql_insert)
        ### write local insert to sql file
        sql_insert_local = sql_insert_strings['local'].format(
                local_prefix + locais.replace('_', ' '),
                id_sessao
                )
        sql_file.write(sql_insert_local)
    
        write_random_tickets_group(id_sessao)   

        id_sessao+=1


def write_random_tickets_group(id_sessao):
    pass


def write_random_tickets(id_sessao):
    pass

if __name__ == '__main__':

    con = create_engine(
        'postgresql+psycopg2://guima:aliaskm1d2dww@localhost/tickets4u')
    
    id_sessao = 0;
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



