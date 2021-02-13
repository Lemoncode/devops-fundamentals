
exports.seed = function(knex) {
  // Deletes ALL existing entries
  return knex('words').del()
    .then(function () {
      // Inserts seed entries
      return knex('words').insert([
        {entry: 'shirt', category: 'clothes'},
        {entry: 'football', category: 'sports'},
        {entry: 'car', category: 'vehicles'},
      ]);
    });
};
