
exports.up = function(knex) {
  return knex.schema.createTable('games', function(table) {
      table.increments();
      table.integer('player_id').references('id').inTable('players');
      table.integer('word_id').references('id').inTable('words');
      table.enu('game_state', ['not_started', 'started', 'finished'], { useNative: true, enumName: 'progress'});
      table.timestamp('created_at').defaultTo(knex.fn.now());
      table.timestamp('updated_at').defaultTo(knex.fn.now());
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('games');
};
