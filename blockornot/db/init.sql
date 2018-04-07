BEGIN;

CREATE TABLE category (
    category_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT
);

CREATE TABLE website (
    website_uri     TEXT PRIMARY KEY,
    category_id     INTEGER REFERENCES category(category_id),
    country         TEXT,
    search_input    TEXT
);

CREATE TABLE status_cache (
    website_uri     TEXT REFERENCES website(website_uri),
    content         JSON,
    ctime           INTEGER
);

INSERT
INTO        category (name)
SELECT      'Local Independent' AS "name"
UNION ALL
SELECT      'Local Mainstream'
UNION ALL
SELECT      'International';

INSERT
INTO        website (website_uri, search_input, country, category_id)
SELECT      'bfm.my' AS website_uri, 'bfm.my' AS search_input, 'MY' AS country, (SELECT category_id FROM category WHERE name = 'Local Independent') AS category_id
UNION ALL
SELECT      'dailyexpress.com.my', 'dailyexpress.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Independent')
UNION ALL
SELECT      'malaysiakini.com', 'malaysiakini.com', 'MY', (SELECT category_id FROM category WHERE name = 'Local Independent')
UNION ALL
SELECT      'malaysiakini.tv', 'malaysiakini.tv', 'MY', (SELECT category_id FROM category WHERE name = 'Local Independent')
UNION ALL
SELECT      'ocdn.com.my', 'ocdn.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Independent')
UNION ALL
SELECT      'theedgedaily.com', 'theedgedaily.com', 'MY', (SELECT category_id FROM category WHERE name = 'Local Independent')
UNION ALL
SELECT      'themalaymailonline.com', 'themalaymailonline.com', 'MY', (SELECT category_id FROM category WHERE name = 'Local Independent');

INSERT
INTO        website (website_uri, search_input, country, category_id)
SELECT      'bharian.com.my' AS website_uri, 'bharian.com.my' AS search_input, 'MY' AS country, (SELECT category_id FROM category WHERE name = 'Local Mainstream') AS category_id
UNION ALL
SELECT      'chinapress.com.my', 'chinapress.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'enanyang.my', 'enanyang.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'guangming.com.my', 'guangming.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'nanban2u.com.my', 'nanban2u.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'nst.com.my', 'nst.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'orientaldaily.com.my', 'orientaldaily.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'sinchew.com.my', 'sinchew.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'thestar.com.my', 'thestar.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'utusan.com.my', 'utusan.com.my', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream')
UNION ALL
SELECT      'vanakkammalaysia.com', 'vanakkammalaysia.com', 'MY', (SELECT category_id FROM category WHERE name = 'Local Mainstream');

INSERT
INTO        website (website_uri, search_input, country, category_id)
SELECT      'asiasentinel.com' AS website_uri, 'asiasentinel.com' AS search_input, 'MY' AS country, (SELECT category_id FROM category WHERE name = 'International') AS category_id
UNION ALL
SELECT      'channelnewsasia.com', 'channelnewsasia.com', 'MY', (SELECT category_id FROM category WHERE name = 'International')
UNION ALL
SELECT      'dunia.tempo.co', 'dunia.tempo.co', 'MY', (SELECT category_id FROM category WHERE name = 'International')
UNION ALL
SELECT      'msnbc.msn.com', 'msnbc.msn.com', 'MY', (SELECT category_id FROM category WHERE name = 'International')
UNION ALL
SELECT      'ft.com', 'ft.com', 'MY', (SELECT category_id FROM category WHERE name = 'International')
UNION ALL
SELECT      'wsj.com', 'wsj.com', 'MY', (SELECT category_id FROM category WHERE name = 'International')
UNION ALL
SELECT      'cnn.com', 'cnn.com', 'MY', (SELECT category_id FROM category WHERE name = 'International')
UNION ALL
SELECT      'bbc.com', 'bbc.com', 'MY', (SELECT category_id FROM category WHERE name = 'International');

END;
