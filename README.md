# Deck AI — Análisis personal de partidas de Clash Royale

Pipeline ETL que descarga mis partidas desde la API oficial de Clash Royale,
las guarda en PostgreSQL y permite analizar mi rendimiento por modo, mazo y
arquetipo rival.

## Por qué

La API solo conserva las últimas ~40 partidas de cada jugador. Este proyecto
las acumula sin duplicados para construir un historial propio y responder
preguntas que las herramientas globales no responden: cómo me va **a mí**,
en **mi liga**, contra los mazos que **de verdad** me encuentro.

## Stack

- Python 3 (`requests`, `psycopg`, `python-dotenv`)
- PostgreSQL 18
- API oficial de Clash Royale vía proxy de RoyaleAPI

## Estructura

```
deck-ai/
├── sql/
│   ├── schema.sql   # tablas
│   └── views.sql    # vistas de análisis
└── src/
    └── ingest.py    # descarga y carga de partidas
```

## Modelo de datos

- `raw_battles`: JSON completo de cada partida, para reprocesar sin volver a la API.
- `battles`: una fila por partida (modo, liga, fecha).
- `battle_players`: los dos jugadores (coronas, vida de torres, elixir desperdiciado).
- `battle_cards`: las 8 cartas de cada lado, con nivel y forma (normal, evolución o héroe).
- `cards`: catálogo de cartas.
- `battle_notes`: etiquetas para partidas atípicas (rival AFK, rendición...).

## Instalación

1. **Clave de la API.** Crea una cuenta en
   [developer.clashroyale.com](https://developer.clashroyale.com) y genera una
   clave autorizando la IP `45.79.218.79`, que es la del proxy de RoyaleAPI.
   Así la clave funciona aunque tu IP cambie.

2. **Entorno de Python:**

```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
```

3. **Variables de entorno.** Copia la plantilla y rellena tu token y tu tag:

```bash
   cp .env.example .env
```

4. **Base de datos** (PostgreSQL):

```bash
   createdb deck_ai
   psql deck_ai -f sql/schema.sql
   psql deck_ai -f sql/views.sql
```

## Uso

```bash
python src/ingest.py
```

Descarga tus últimas partidas y guarda solo las nuevas. Ejecútalo con
regularidad: la API conserva unas 40 partidas por jugador.

Para ver tus partidas con el mazo rival:

```sql
SELECT * FROM v_partidas ORDER BY battle_time DESC;
```

## Hallazgos de los datos

- `elixirLeaked` vale siempre 0 en las batallas de barco: se excluyen del análisis de elixir.
- `evolutionLevel` distingue la forma de la carta: 0 normal, 1 evolución, 2 héroe.
- Los niveles usan una escala distinta por rareza: una carta está al máximo cuando `level = maxLevel`.

## Próximos pasos

- [ ] Automatizar la ingesta
- [ ] Importar historial antiguo desde CSV
- [ ] Clasificador de arquetipos rivales
- [ ] Dashboard de progreso