# Deck AI — Análisis personal de partidas de Clash Royale

Pipeline ETL que descarga mis partidas desde la API oficial de Clash Royale,
las guarda en PostgreSQL y permite analizar mi rendimiento por modo, mazo y
arquetipo rival.

🎮 **Pruébalo:** [Elixir Lab](https://nicolay008.github.io/deck-ai/), un minijuego para entrenar el conteo de elixir.

## Por qué

La API solo conserva las últimas ~40 partidas de cada jugador. Este proyecto
las acumula sin duplicados para construir un historial propio y responder
preguntas que las herramientas globales no responden: cómo me va **a mí**,
en **mi liga**, contra los mazos que **de verdad** me encuentro.

## Stack

- Python 3 (`requests`, `psycopg`, `python-dotenv`)
- PostgreSQL 18
- API oficial de Clash Royale vía proxy de RoyaleAPI
- HTML, CSS y JavaScript sin dependencias para Elixir Lab, publicado con GitHub Pages

## Estructura

```
deck-ai/
├── docs/                 # Elixir Lab (GitHub Pages)
│   ├── index.html        # el minijuego
│   ├── cards.json        # catálogo generado desde la API
│   └── nombres_es.json   # nombres de las cartas en español
├── sql/
│   ├── schema.sql        # tablas
│   └── views.sql         # vistas de análisis
└── src/
    ├── ingest.py         # descarga y carga de partidas
    └── export_cards.py   # genera docs/cards.json
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
regularidad: la API conserva unas 30-40 partidas por jugador.

### Ingesta automática (Windows + WSL)

Una tarea del Programador de tareas de Windows ejecuta la ingesta cada 4 horas
mientras el PC está encendido. PostgreSQL arranca solo con WSL gracias a
`sudo systemctl enable postgresql`. La acción de la tarea es:

```
wsl.exe -d Ubuntu -u <usuario> -- bash -lc "cd ~/Proyectos/deck-ai && date >> logs/ingest.log && .venv/bin/python src/ingest.py >> logs/ingest.log 2>&1"
```

El resultado de cada ejecución queda en `logs/ingest.log` (excluido de git).

Para ver tus partidas con el mazo rival:

```sql
SELECT * FROM v_partidas ORDER BY battle_time DESC;
```

## Elixir Lab

Mis datos mostraban que gran parte de mis derrotas venía de malas decisiones
de elixir. Elixir Lab entrena esa habilidad con dos modos:

- **Adivina el coste:** sale una carta y marcas su coste antes de que se agote el tiempo.
- **Cuenta su elixir:** el rival juega cartas y pasa el tiempo; tú calculas cuánto elixir le queda.

Guarda notas sobre 20, récords y un gráfico de progreso por nivel. Los costes
salen de la API oficial: para actualizarlos, ejecuta `python src/export_cards.py`
y añade a `docs/nombres_es.json` el nombre en español de las cartas nuevas que
indique.

## Hallazgos de los datos

- `elixirLeaked` vale siempre 0 en las batallas de barco: se excluyen del análisis de elixir.
- `evolutionLevel` distingue la forma de la carta: 0 normal, 1 evolución, 2 héroe.
- Los niveles usan una escala distinta por rareza: una carta está al máximo cuando `level = maxLevel`.

## Hoja de ruta

### Fase 1 — Datos propios (en curso)
- [x] Ingesta desde la API oficial sin duplicados
- [x] Modelo de datos en PostgreSQL con JSON crudo
- [x] Vista de partidas con evoluciones y héroes del rival
- [x] Etiquetado de partidas atípicas
- [x] Automatizar la ingesta
- [ ] Importar historial antiguo desde CSV

### Fase 2 — Análisis
- [ ] Clasificador de arquetipos rivales (carta ancla + coste medio de elixir)
- [ ] Winrate y elixir desperdiciado por arquetipo, modo y variante de mazo
- [ ] Dashboard de progreso

### Fase 3 — Visión por computadora
- [ ] Reconocer cartas jugadas en repeticiones grabadas
- [ ] Medir intercambios de elixir jugada a jugada

### Fase 4 — Entrenador de decisiones
- [x] Elixir Lab: entrenamiento de costes y conteo de elixir
- [ ] Situaciones de partida con respuestas de referencia
      (decisiones de jugadores top y reglas propias)
- [ ] Puntuación por intercambio de elixir

## Nota

Este proyecto analiza partidas ya jugadas y entrena habilidades fuera del juego.
No automatiza ni interactúa con Clash Royale.

Elixir Lab es material no oficial y no está respaldado por Supercell. Consulta la
[política de contenido de fans de Supercell](https://www.supercell.com/fan-content-policy).

## Licencia

MIT