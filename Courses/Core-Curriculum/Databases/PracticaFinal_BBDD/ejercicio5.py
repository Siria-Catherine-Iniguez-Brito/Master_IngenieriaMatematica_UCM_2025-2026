import random
import datetime
from faker import Faker
import secrets
import hashlib

# Configuración inicial
semilla = 2026
random.seed(semilla)
Faker.seed(semilla)
fake = Faker('es_ES')

# Volumetría requerida por el enunciado
SCENARIOS = {
    "6_meses": {"users": 25000, "movies": 3500, "audiobooks": 1200, "series": 300, "actors": 4000},
    "1_ano": {"users": 40000, "movies": 5500, "audiobooks": 2000, "series": 500, "actors": 6000}
}

GENEROS = ["Acción", "Comedia", "Drama", "Ciencia Ficción", "Terror", "Romance", "Documental",
           "Misterio", "Musical", "Animación", "Thriller", "Fantasía", "Histórico"]
IDIOMAS = ["Español", "Inglés", "Francés", "Alemán", "Italiano", "Portugués"]
PAISES = ["España", "México", "Argentina", "Colombia", "Chile", "Perú", "Portugal"]


def esc(text):
    return str(text).replace("'", "''")


def generate_sql(scenario_name):
    conf = SCENARIOS[scenario_name]
    filename = f"poblacion_{scenario_name}.sql"
    print(f"Generando {filename}...")

    # Diccionario para controlar la duración real de cada contenido
    duraciones_contenido = {}

    with open(filename, "w", encoding="utf-8") as f:
        f.write("SET FOREIGN_KEY_CHECKS=0;\n")
        f.write("SET UNIQUE_CHECKS=0;\n")
        f.write("SET SQL_LOG_BIN=0;\n")
        f.write("SET AUTOCOMMIT=0;\n")
        f.write("START TRANSACTION;\n\n")

        def write_batch(table, columns, values_list):
            if not values_list: return
            f.write(f"INSERT INTO `{table}` ({', '.join(['`' + c + '`' for c in columns])}) VALUES \n")
            f.write(",\n".join(values_list) + ";\n")

        # 1. TABLAS MAESTRAS
        f.write("INSERT IGNORE INTO `idioma` (`idioma`) VALUES " + ",".join([f"('{i}')" for i in IDIOMAS]) + ";\n")
        f.write("INSERT IGNORE INTO `pais` (`pais`) VALUES " + ",".join([f"('{p}')" for p in PAISES]) + ";\n")
        f.write("INSERT IGNORE INTO `plan` (`id`, `precio`, `nombre_plan`, `fecha_creacion`) VALUES " +
                "(1, 5.99, 'Básico', '2023-01-01'), (2, 9.99, 'Estándar', '2023-01-01'), (3, 14.99, 'Premium', '2023-01-01');\n")

        # 2. ACTORES
        actor_ids = list(range(1, conf['actors'] + 1))
        actors_data = [f"({i}, '{esc(fake.name())}', NULL, '{fake.date_of_birth(minimum_age=20, maximum_age=80)}')" for
                       i in actor_ids]
        write_batch("actor", ["id", "nombre", "fotografia", "fecha_nacimiento"], actors_data)

        # 3. CONTENIDO (Películas, Audiolibros, Series)
        content_id = 1
        movie_cont, peli_det, reparto_p, idioma_c, disp_c = [], [], [], [], []

        # Películas
        for _ in range(conf['movies']):
            dur = random.randint(80, 180)
            duraciones_contenido[content_id] = dur
            movie_cont.append(
                f"({content_id}, '{fake.date_this_decade()}', '{random.choice(GENEROS)}', {random.choice([0, 7, 12, 16, 18])}, {dur}, 0, NULL)")
            peli_det.append(f"({content_id}, '{esc(fake.name())}')")
            for a_id in random.sample(actor_ids, random.randint(2, 10)):
                reparto_p.append(f"({content_id}, {a_id})")
            idioma_c.append(f"({content_id}, '{random.choice(IDIOMAS)}')")
            disp_c.append(f"({random.randint(1, 3)}, {content_id}, '2024-01-01')")
            content_id += 1

        # Audiolibros
        audio_cont, audio_det = [], []
        for _ in range(conf['audiobooks']):
            dur = random.randint(120, 600)
            duraciones_contenido[content_id] = dur
            audio_cont.append(
                f"({content_id}, '{fake.date_this_decade()}', '{random.choice(GENEROS)}', 0, {dur}, 0, NULL)")
            audio_det.append(f"({content_id}, '{esc(fake.name())}', '{esc(fake.name())}')")
            idioma_c.append(f"({content_id}, '{random.choice(IDIOMAS)}')")
            disp_c.append(f"({random.randint(1, 3)}, {content_id}, '2024-01-01')")
            content_id += 1

        # Series y Capítulos
        serie_det, cap_cont, cap_det, reparto_c = [], [], [], []
        for i in range(conf['series']):
            s_nombre = esc(f"S{i}_{fake.word()}")
            n_temps = random.randint(1, 5)
            serie_det.append(f"('{s_nombre}', {n_temps})")
            for t in range(1, n_temps + 1):
                num_caps = random.randint(6, 12)
                for c in range(1, num_caps + 1):
                    dur = random.randint(20, 60)
                    duraciones_contenido[content_id] = dur
                    cap_cont.append(
                        f"({content_id}, '{fake.date_this_decade()}', '{random.choice(GENEROS)}', 12, {dur}, 0, NULL)")
                    cap_det.append(f"({content_id}, {c}, {t}, 'Cap {c}', '{s_nombre}')")
                    for a_id in random.sample(actor_ids, random.randint(2, 10)):
                        reparto_c.append(f"({content_id}, {a_id})")
                    idioma_c.append(f"({content_id}, '{random.choice(IDIOMAS)}')")
                    disp_c.append(f"({random.randint(1, 3)}, {content_id}, '2024-01-01')")
                    content_id += 1

        # Inserción masiva de contenidos
        write_batch("contenido",
                    ["id", "fecha_publicacion", "genero", "clasificacion_edad", "duracion", "borrado_backoffice",
                     "fecha_borrado_backoffice"], movie_cont + audio_cont + cap_cont)
        write_batch("pelicula", ["id", "director"], peli_det)
        write_batch("reparto_peli", ["id_pelicula", "id_actor"], reparto_p)
        write_batch("audiolibro", ["id", "autor", "narrador"], audio_det)
        write_batch("serie", ["nombre_serie", "n_temporadas"], serie_det)
        write_batch("capitulo", ["id", "numero", "temporada", "nombre_capitulo", "id_serie"], cap_det)
        write_batch("reparto_cap", ["id_capitulo", "id_actor"], reparto_c)
        write_batch("idioma_contenido", ["id_contenido", "idioma"], idioma_c)
        write_batch("disponible", ["id_plan", "id_contenido", "fecha"], disp_c)

        f.write("COMMIT; START TRANSACTION;\n")

        # 4. USUARIOS Y CREDENCIALES
        user_emails = []
        u_batch, c_batch = [], []
        for i in range(conf['users']):
            email = f"user{i}_{secrets.token_hex(3)}@stream.com"
            user_emails.append(email)
            has_plan = random.random() < 0.78  # 78% tienen plan activo
            id_p = random.randint(1, 3) if has_plan else "NULL"
            f_adq = f"'{fake.date_this_year()}'" if has_plan else "NULL"

            # MD5 en Python para ganar velocidad
            pwd_plain = secrets.token_urlsafe(12)
            hash_pwd = hashlib.md5(pwd_plain.encode()).hexdigest()

            u_batch.append(
                f"('{email}', '{esc(fake.first_name())}', '{esc(fake.last_name())}', '{fake.date_of_birth(minimum_age=18, maximum_age=70)}', '2023-01-01', {id_p}, {f_adq})")
            c_batch.append(f"('{email}', '{hash_pwd}')")

            if len(u_batch) >= 5000:
                write_batch("usuario", ["email", "nombre", "apellidos", "fecha_nacimiento", "fecha_registro", "id_plan",
                                        "fecha_adquisicion"], u_batch)
                write_batch("usuario_credencial", ["email", "password_hash"], c_batch)
                f.write("COMMIT; START TRANSACTION;\n")
                u_batch, c_batch = [], []

        write_batch("usuario", ["email", "nombre", "apellidos", "fecha_nacimiento", "fecha_registro", "id_plan",
                                "fecha_adquisicion"], u_batch)
        write_batch("usuario_credencial", ["email", "password_hash"], c_batch)

        # 5. SEGUIDORES
        s_batch = []
        for email in user_emails:
            # Cada usuario sigue entre 0 y 50 usuarios
            targets = random.sample(user_emails, random.randint(0, 50))
            for t in targets:
                if email != t:
                    s_batch.append(f"('{email}', '{t}')")
                    if len(s_batch) >= 10000:
                        write_batch("seguir", ["id_usuario_seguidor", "id_usuario_seguido"], s_batch)
                        f.write("COMMIT; START TRANSACTION;\n")
                        s_batch = []
        write_batch("seguir", ["id_usuario_seguidor", "id_usuario_seguido"], s_batch)

        # 6. ACCIONES
        all_ids = list(duraciones_contenido.keys())
        a_batch = []
        global_action_count = 0
        for email in user_emails:
            # Cada usuario interactúa con entre 100 y 400 contenidos
            selection = random.sample(all_ids, random.randint(100, 400))
            for c_id in selection:
                r = random.random()
                visto = 0
                momento = 0
                dur_max = duraciones_contenido[c_id]

                # Distribución: 60% vistos, 20% abandonados
                if r < 0.60:
                    visto = 1
                    momento = dur_max
                elif r < 0.80:
                    visto = 0
                    momento = random.randint(1, dur_max - 1)  # Abandonado: empezado pero no terminado

                # Independientes: 30% favoritos, 40% puntuados
                fav = 1 if random.random() < 0.30 else 0
                punt = random.randint(1, 5) if random.random() < 0.40 else "NULL"

                a_batch.append(f"('{email}', {c_id}, {punt}, {momento}, {visto}, {fav})")
                global_action_count += 1

                if len(a_batch) >= 20000:
                    write_batch("accion",
                                ["id_usuario", "id_contenido", "puntuacion", "momento_parada", "visto", "favorito"],
                                a_batch)
                    a_batch = []
                    if global_action_count % 100000 == 0:
                        f.write("COMMIT; START TRANSACTION;\n")

        write_batch("accion", ["id_usuario", "id_contenido", "puntuacion", "momento_parada", "visto", "favorito"],
                    a_batch)

        f.write("\nCOMMIT;\nSET FOREIGN_KEY_CHECKS=1;\n")
        print(f"Finalizado con éxito: {filename}")


# Ejecución para ambos escenarios
generate_sql("6_meses")
generate_sql("1_ano")