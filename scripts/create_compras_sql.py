import string 
import datetime
from pprint import pprint
from sqlalchemy import create_engine
import random
from tqdm import tqdm
import pickle


def random_date(start,l):
   current = start
   while l >= 0:
      curr = current + datetime.timedelta(days=random.randrange(60))
      yield curr
      l-=1


if __name__ == '__main__':


    con = create_engine(
        'postgresql+psycopg2://guima:aliaskm1d2dww@localhost/tickets4u')
    
    with open('população_db/compras.sql', 'w') as sql_file:

        sql_file.write('set search_path to tickets4u;')
    
        clientes = con.execute('''
			set search_path to tickets4u;
                        SELECT cpf FROM cliente
			''').fetchall()
        max_bilhete = con.execute('''
			set search_path to tickets4u;
                        SELECT max(id_bilhete) FROM bilhete
			''').fetchall()[0][0]

        bilhetes_comprados = set()

        sql_insert = '''
        
        INSERT INTO compra(cpf_comprador, forma_de_pagto, data_compra, id_bilhete) Values(
        
            {cpf_comprador}, '{forma_de_pagto}', now(), {id_bilhete}
        
        );\n
        
        '''

        for cliente in tqdm(clientes):
            executa_compra = random.choices([True, False], weights=(0.3, 0.7))[0]

            if executa_compra:

                total_de_compras = random.randint(1, 6)

                for compra in range(total_de_compras):
                    bilhete = random.randint(0, max_bilhete)
                    while bilhete in bilhetes_comprados:
                        bilhete = random.randint(0, max_bilhete)
                        bilhetes_comprados.add(bilhete)

                    sql_file.write(sql_insert.format(
                            cpf_comprador=int(cliente[0]), 
                            forma_de_pagto=random.choice(['cc', 'bl']),
                            id_bilhete = bilhete)
                        )



                

     

