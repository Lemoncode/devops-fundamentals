
exports.up = function(knex) {
    return knex.schema.createTable('words', function(table) {
        table.increments();
        table.string('entry').notNullable();
        table.enu('word_category', ['clothes', 'sports', 'vehicles'], { useNative: true, enumName: 'category'});
        table.timestamp('created_at').defaultTo(knex.fn.now());
        table.timestamp('updated_at').defaultTo(knex.fn.now());
    });
};

exports.down = function(knex) {
    return knex.schema.dropTable('words');
};
