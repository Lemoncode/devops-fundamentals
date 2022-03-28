export enum WordCategoryEntity {
    Clothes = 'clothes',
    Sports = 'sports',
    Vehicles = 'vehicles',
}

export interface WordEntity {
    id?: number;
    word_category: WordCategoryEntity;
    entry: string;
    created_at?: string;
    updated_at?: string;
}
