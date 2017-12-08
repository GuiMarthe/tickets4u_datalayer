from pprint import pprint
from sqlalchemy import create_engine
from imdb import IMDb
import random
from tqdm import tqdm
import pickle

api = IMDb()


sql_insert_strings = {
    'cinema': "INSERT INTO filme values({id_evento}, '{titulo}', '{sinopse}', '{genero}','{dub}','{duracao}', '{direcao}', '{distribuicao}', '{tipo_exibicao}', '{produtora}');\n",

    'casa_de_shows': "INSERT INTO show Values({id_evento}, '{artista}', '{genero}', '{local}');\n",
    'estadio': "INSERT INTO esporte Values({id_evento}, '{tipo_esporte}', '{competidores}');\n",
    'teatro': "INSERT INTO peca_teatro Values({id_evento}, '{titulo}', '{descricao}', '{genero}', '{dub}', '{direcao}', '{duracao}');\n"
}


def get_movies(n, movie_choices):

    rr = []

    for i, movie in enumerate(movie_choices):
        if i > n:
            break

        dd = {
            'titulo':       str(movie['title']).replace("'", ""),
            'sinopse':      str(movie.get('plot outline', ['Nao disponivel'][0])).replace("'", ""),
            'genero':       str(movie.get('genre', ['Nao disponivel'])[0]).replace("'", ""),
            'direcao':      str(movie.get('director', ['Nao disponivel'])[0]).replace("'", ""),
            'distribuicao': str(movie.get('distributor', ['Nao disponivel'])[0]).replace("'", ""),
            'tipo_exibicao': str(random.choice(['3d', '4d', 'normal'])).replace("'", ""),
            'produtora':    str(movie.get('production companies', ['Nao disponivel'])[0]).replace("'", ""),
            'dub':          random.choice([True, False]),
            'duracao':      str(movie.get('runtimes', ['Nao disponivel'])[0]).replace("'", "")
        }
        rr.append(dd)

    return(rr)


def get_concerts(n, movie_choices):
    rr = []

    for i, movie in enumerate(movie_choices):
        if i > n:
            break
        dd = {
            'artista': str(movie.get('original music', ['Nao_disponivel'])[0]).replace("'", ""),
            'genero':  random.choice('rock samba trilha_sonora eletronico pagode sertanejo jazz blues'.split()),
            'local':   None  # will be added whe writing to the db
        }

        rr.append(dd)

    return(rr)


def get_sports(n, movie_choices):
    esportes = {'basquete': 'cleaveland oklahoma charlotte chicago new_york brooklyn philadelphia'.split(),
                'futebol': 'corinthians palmeiras santos sao_paulo gremio atletico_mineiro botafogo fluminense flamengo'.split()}
    rr = []
    i = 0
    while i < n:
        esporte = random.choice('basquete futebol'.split())
        times = random.choices(esportes[esporte], k=2)
        dd = {'tipo_esporte': esporte, 'competidores': ' X '.join(times)}
        rr.append(dd)
        i += 1
    return(rr)


def get_plays(n, movie_choices):

    rr = []

    for i, movie in enumerate(movie_choices):
        if i > n:
            break

        dd = {
            'titulo':       str(movie['title']).replace("'", ""),
            'descricao':      str(movie.get('plot outline', ['Nao disponivel'])[0]).replace("'", ""),
            'genero':       str(movie.get('genre', ['Nao disponivel'])[0]).replace("'", ""),
            'dub':          random.choice([True, False]),
            'direcao':      str(movie.get('director', ['Nao disponivel'])[0]).replace("'", ""),
            'duracao':      str(movie.get('runtimes', ['Nao disponivel'])[0]).replace("'", "")
        }
        rr.append(dd)

    return(rr)


def write_sql_statements(text_file, tipo, detalhes, id_eventos):
    print(f'WRITING INSERTS FOR {tipo}')
    for id_evento, detalhe in zip(tqdm(id_eventos), detalhes):
        detalhe['id_evento'] = id_evento
        text_file.write(sql_insert_strings[tipo].format(**detalhe))


if __name__ == '__main__':

    top250 = api.get_top250_movies()

    con = create_engine(
        'postgresql+psycopg2://guima:aliaskm1d2dww@localhost/tickets4u')

    with open('análises/total_eventos_por_tipo_estabelecimento.sql') as query_file:
        totals_query = query_file.read()

    result = con.execute('set search_path to tickets4u;' + totals_query)

    classes_to_populate = result.fetchall()

    max_entries = max([n for event_type, n in classes_to_populate])

    try:
        with open('.cache/movie_choices.pck', 'rb') as file:
            movie_choices = pickle.load(file)
        print('got data from file')
    except (FileNotFoundError, EOFError):
        movie_choices = [api.get_movie(movie.getID())
                         for movie in tqdm(random.choices(top250, k=max_entries))]
        with open('.cache/movie_choices.pck', 'wb') as file:
            pickle.dump(movie_choices, file)

    with open('./população_db/popula_subclasse_eventos.sql', 'w') as sql_file:

        sql_file.write('set search_path to tickets4u;')

        query_eventos = '''
        SELECT evento.id_evento FROM EVENTO NATURAL JOIN EMPRESA 
        WHERE EMPRESA.TIPO_ESTABELECIMENTO = %(tipo)s
        '''
        for tipo, n in classes_to_populate:

            eventos = con.execute('set search_path to tickets4u;' + query_eventos,
                                  {'tipo': tipo})

            id_eventos = [i[0] for i in eventos]

            if tipo == 'cinema':

                detalhes = get_movies(n, movie_choices)

            if tipo == 'casa_de_shows':

                detalhes = get_concerts(n, movie_choices)

            if tipo == 'estadio':

                detalhes = get_sports(n, movie_choices)

            if tipo == 'teatro':

                detalhes = get_plays(n, movie_choices)

            write_sql_statements(sql_file, tipo, detalhes, id_eventos)

        print('end of stuff')
