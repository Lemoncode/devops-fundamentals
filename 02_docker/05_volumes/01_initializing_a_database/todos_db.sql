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
