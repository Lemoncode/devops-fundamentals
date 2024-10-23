# Initializing A Database

The initialization of a database depends on the database that we want to interact with, but the bases, in almost all databases are the same. As case study we're going to use postgresql. Let's start by just getting up a database and interact with the container.

```bash
docker run -d --name postgres postgres:10.4
```

If we run `docker volume ls`, we will notice that a new volume has been created, by default almost all database images will do the same, will delegate the persistent data to the host through a volume. Ok let's create some useful data inside:

```bash
docker exec -it postgres psql -U postgres
```

Once we're inside the database server we can use SQL

```sql
CREATE DATABASE todos_db;

\c todos_db

CREATE TABLE todos (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    completed boolean NOT NULL,
    due_date timestamp with time zone,
    "order" integer
);

```

And insert some data as follows

```sql
COPY todos (id, title, completed, due_date, "order") FROM stdin;
12	Learn Jenkins	f	2020-12-04 18:37:44.234+00	\N
13	Learn GitLab	t	2020-12-04 18:38:06.993+00	\N
21	Learn K8s	f	2020-12-04 19:12:16.174+00	\N
\.
```

Now if we stop our container `docker stop postgres` and now we restart the same container `docker restart postgres` we can check that the data stills there. That's because the default volume that is created when we have created the database.

Let's say because is an anonymous volume this is something that is prune to be lost, so let's create our own image that always create the same dabase.

Create `todos_db.sql`

```sql
CREATE DATABASE todos_db;

\c todos_db

CREATE TABLE todos (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    completed boolean NOT NULL,
    due_date timestamp with time zone,
    "order" integer
);

INSERT INTO todos (id, title, completed, due_date)
VALUES (12,	'Learn Jenkins', 'false', '2020-12-04 18:37:44.234+00');

INSERT INTO todos (id, title, completed, due_date)
VALUES (13,	'Learn GitLab', 'true', '2020-12-04 18:37:44.234+00');

INSERT INTO todos (id, title, completed, due_date)
VALUES (21,	'Learn K8s', 'false', '2020-12-04 18:37:44.234+00');

```

```Dockerfile
FROM postgres:10.4

COPY ./todos_db.sql /docker-entrypoint-initdb.d
```

And build the image with a fancy name easy to remind ;)

```bash
docker build -t jaimesalas/todos_db .
```

Now, let's see if this has worked

```bash
docker run -d --name db1 jaimesalas/todos_db
docker exec -it db1 psql -U postgres
```

And run `\l` inside `psql` terminal, we can check that the database is there. Why? Because there is an anonymous volume created by docker, that will be initialized from our custom image. Let's clean the previous container:

```bash
docker stop db1 && docker rm db1
```

And run again 

```bash
docker run -d --name db1 jaimesalas/todos_db
docker exec -it db1 psql -U postgres
```

In `psql` console we run the following commands:

```
\c todos_db
SELECT * FROM todos;
        ^
todos_db=# SELECT * FROM todos;
 id |     title     | completed |          due_date          | order 
----+---------------+-----------+----------------------------+-------
 12 | Learn Jenkins | f         | 2020-12-04 18:37:44.234+00 |      
 13 | Learn GitLab  | t         | 2020-12-04 18:37:44.234+00 |      
 21 | Learn K8s     | f         | 2020-12-04 18:37:44.234+00 |      
(3 rows)
```

Now let's insert a new todo

```sql
INSERT INTO todos (id, title, completed, due_date)
VALUES (22,	'Review AWS cli', 'false', '2020-12-12 18:37:44.234+00');
```

And check that the new record is there

```
SELECT * FROM todos;
 id |     title      | completed |          due_date          | order 
----+----------------+-----------+----------------------------+-------
 12 | Learn Jenkins  | f         | 2020-12-04 18:37:44.234+00 |      
 13 | Learn GitLab   | t         | 2020-12-04 18:37:44.234+00 |      
 21 | Learn K8s      | f         | 2020-12-04 18:37:44.234+00 |      
 22 | Review AWS cli | f         | 2020-12-12 18:37:44.234+00 |      
(4 rows)
```

Ok, now let's clean previous container, and run again, what is going to happen with the last record that we've inserted?

```bash
docker kill db1 && docker rm db1
docker run -d --name db1 jaimesalas/todos_db
docker exec -it db1 psql -U postgres
```

Obviously the last record is not there, because remind, that all the times that this container, starts up, it will create a new `volume` and populate, with the inner `sql` script.

To handle this situation, we can create a volume and recreate the previous steps

```bash
docker run -d --name db1 -v todos_db:/var/lib/postgresql/data jaimesalas/todos_db
docker exec -it db1 psql -U postgres
```

Insert the record `\c todos_db`

```sql
INSERT INTO todos (id, title, completed, due_date)
VALUES (22,	'Review AWS cli', 'false', '2020-12-12 18:37:44.234+00');
```

If we clear the previous container

```bash
docker kill db1 && docker rm db1
```

And run it again we can check that the data is there

```bash
docker run -d --name db1 -v todos_db:/var/lib/postgresql/data jaimesalas/todos_db
docker exec -it db1 psql -U postgres
```

```
SELECT * FROM todos;
 id |     title      | completed |          due_date          | order 
----+----------------+-----------+----------------------------+-------
 12 | Learn Jenkins  | f         | 2020-12-04 18:37:44.234+00 |      
 13 | Learn GitLab   | t         | 2020-12-04 18:37:44.234+00 |      
 21 | Learn K8s      | f         | 2020-12-04 18:37:44.234+00 |      
 22 | Review AWS cli | f         | 2020-12-12 18:37:44.234+00 |      
(4 rows)
```