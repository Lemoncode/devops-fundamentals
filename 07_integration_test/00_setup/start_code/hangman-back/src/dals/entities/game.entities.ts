export enum GameStateEntity {
    NotStarted = 'not_started',
    Started = 'started',
    Finished = 'finished',
}

export interface GameEntity {
    id?: number;
    player_id: number;
    word_id: number;
    game_state: GameStateEntity
    created_at?: string;
    updated_at?: string;
}