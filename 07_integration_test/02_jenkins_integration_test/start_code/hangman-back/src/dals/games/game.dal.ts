import Knex from 'knex';
import { GameDALFactory } from './game.contract.dal';
import { GameEntity } from '../entities';

export const gameDALFactory: GameDALFactory = (knex: Knex) => ({
  getGames(playerId: number): Promise<GameEntity[]> {
    return knex<GameEntity>('games').where('player_id', playerId);
  },
});
