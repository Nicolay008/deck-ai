CREATE TABLE IF NOT EXISTS raw_battles (
    battle_id   TEXT PRIMARY KEY,
    payload     JSONB NOT NULL,
    fetched_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS cards (
    card_id      INT PRIMARY KEY,
    name         TEXT NOT NULL,
    rarity       TEXT,
    elixir_cost  INT,
    max_level    INT
);

CREATE TABLE IF NOT EXISTS battles (
    battle_id     TEXT PRIMARY KEY REFERENCES raw_battles,
    battle_time   TIMESTAMPTZ NOT NULL,
    type          TEXT,
    game_mode     TEXT,
    league_number INT,
    arena         TEXT,
    is_hosted     BOOLEAN
);

CREATE TABLE IF NOT EXISTS battle_players (
    battle_id      TEXT REFERENCES battles,
    side           TEXT CHECK (side IN ('me','opponent')),
    player_tag     TEXT,
    player_name    TEXT,
    crowns         INT,
    king_tower_hp  INT,
    princess_hp    INT[],
    elixir_leaked  NUMERIC(5,2),
    global_rank    INT,
    PRIMARY KEY (battle_id, side)
);

CREATE TABLE IF NOT EXISTS battle_cards (
    battle_id        TEXT,
    side             TEXT,
    slot             INT,
    card_id          INT REFERENCES cards,
    level            INT,
    evolution_level  INT,
    PRIMARY KEY (battle_id, side, slot),
    FOREIGN KEY (battle_id, side) REFERENCES battle_players
);
