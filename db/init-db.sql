-- create table for castles

CREATE TABLE castles
(
  imageid serial UNIQUE PRIMARY KEY,
  description character varying(10485760) NOT NULL,
  url character varying(255) NOT NULL
);

ALTER TABLE castles
  OWNER TO dockeruser;
ALTER ROLE dockeruser CONNECTION LIMIT -1;

-- add castles data
INSERT INTO castles (description, url) VALUES('A german castle', 'castles/hohenzollern_castle.png');
INSERT INTO castles (description, url) VALUES('Famous Dover Castle', 'castles/dover_castle.png');
INSERT INTO castles (description, url) VALUES('Italian Castle', 'castles/sforzaesco_castle.png');
INSERT INTO castles (description, url) VALUES('Spis Castle', 'castles/spis_castle.png');
INSERT INTO castles (description, url) VALUES('Colorful Pena Castle', 'castles/pena_castle.png');
