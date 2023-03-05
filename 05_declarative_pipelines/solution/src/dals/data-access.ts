import Knex from 'knex';

// type ConnectionParams = PgConnectionConfig & { dbVersion: string };

export const startConnection = ({ ...connection }) => {
  try {
    return Knex({
      client: 'pg',
      connection
    });
  } catch (error) {
    throw error;
  }
};