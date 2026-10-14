CREATE OR REPLACE VIEW v_partidas AS
SELECT b.battle_time, b.type, op.player_name AS rival,
       me.crowns || '-' || op.crowns AS resultado,
       me.crowns > op.crowns AS victoria,
       me.elixir_leaked,
       STRING_AGG(c.name, ', ' ORDER BY bc.slot) AS mazo_rival
FROM battles b
JOIN battle_players me ON me.battle_id = b.battle_id AND me.side = 'me'
JOIN battle_players op ON op.battle_id = b.battle_id AND op.side = 'opponent'
JOIN battle_cards bc ON bc.battle_id = b.battle_id AND bc.side = 'opponent'
JOIN cards c ON c.card_id = bc.card_id
GROUP BY b.battle_id, b.battle_time, b.type, op.player_name,
         me.crowns, op.crowns, me.elixir_leaked;