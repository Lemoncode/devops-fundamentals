import { GameEntity } from '../entities/game.entities';

export interface GameDAL {
    getGames(playerId: number): Promise<GameEntity[]>;
}