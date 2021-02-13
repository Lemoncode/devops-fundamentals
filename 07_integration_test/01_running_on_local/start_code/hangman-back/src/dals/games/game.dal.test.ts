import { db as knex, startConnection } from '../dataAccess';
import { GameEntity, PlayerEntity, WordEntity } from '../entities';
import { gameDALFactory } from './game.dal';

beforeAll(() => {
  //   console.log(process.env)
  startConnection({
    host: process.env.DATABASE_HOST,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    port: +process.env.DATABASE_PORT!,
    database: process.env.DATABASE_NAME,
    dbVersion: process.env.DATABASE_VERSION!,
  });
});

afterAll(async () => {
  await knex.destroy();
});

beforeEach(async () => {
  await knex.from('players').delete();
  await knex.from('words').delete();
  await knex.from('games').delete();
});

describe('game.dal', () => {
  describe('getGames', () => {
    test('returns the games related to a player', async () => {
      // Arrange
      await Promise.all([insertPlayer('joe', 1), insertWord(1, 'car', 'vehicles')]);
      await insertGame(1, 1, 'not_started');
      const gameDAL = gameDALFactory(knex);

      // Act
      const [game] = await gameDAL.getGames(1);
      const { player_id, word_id, game_state } = game;

      // Assert
      expect(player_id).toEqual(1);
      expect(word_id).toEqual(1);
      expect(game_state).toEqual('not_started');
    });
  });
});

const insertPlayer = (name: string, id: number): Promise<PlayerEntity> =>
  knex('players')
    .insert({ id, name }, '*')
    .then(([player]) => player);

const insertWord = (id: number, entry: string, word_category: string): Promise<WordEntity> =>
  knex('words')
    .insert({ id, entry, word_category }, '*')
    .then(([word]) => word);

const insertGame = (player_id: number, word_id: number, game_state: string): Promise<GameEntity> =>
  knex('games')
    .insert({ player_id, word_id, game_state }, '*')
    .then(([game]) => game);
