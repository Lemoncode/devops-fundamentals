import Knex, { PgConnectionConfig } from 'knex';

export let db: Knex;

type ConnectionParams = PgConnectionConfig & { dbVersion: string };

export const startConnection = ({ dbVersion: version, ...connection }: ConnectionParams) => {
  try {
    db = Knex({
      client: 'pg',
      version,
      connection,
    });
  } catch (error) {
    throw error;
  }
};