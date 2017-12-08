from pprint import pprint
from sqlalchemy import create_engine
from imdb import IMDb
import random
from tqdm import tqdm
import pickle

sql_update_string = 'UPDATE evento set num_bilhetes = {bilhetes} where id_evento = {id_evento};\n'

if __name__ == '__main__':
    con = create_engine(
        'postgresql+psycopg2://guima:aliaskm1d2dww@localhost/tickets4u')

    query  = '''
    
    SELECT id_evento,  num_bilhetes, empresa.tipo_estabelecimento
    FROM evento natural join empresa
    '''

    result = con.execute('set search_path to tickets4u;' + query)
    
    with open('./população_db/update_num_bilhetes.sql', 'w') as sql_file:

        sql_file.write('set search_path to tickets4u;\n')

        for tupla in tqdm(result):

            id_evento, num_bilhetes, tipo_estabelecimento = tupla

            if tipo_estabelecimento in ('cinema', 'casa_de_shows'):

                new_num_bilhetes = random.choice(range(30, 200, 10))

            else:
                new_num_bilhetes = random.choice(range(200,300, 10))

            sql_file.write(
                sql_update_string.format(bilhetes = new_num_bilhetes,
                                         id_evento = id_evento)
            )





