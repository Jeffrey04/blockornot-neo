from multiprocessing import Process
from contextlib import closing
from collections import OrderedDict
import logging
import os
import sqlite3
import time
import random

import ujson
import bottle
import requests

logging.basicConfig(level=logging.INFO & logging.ERROR)
logger = logging.getLogger(__name__)

def cache_updater():
    cache_time, site_list = time.time(), tuple()

    while True:
        if time.time() - cache_time > 300 or len(site_list) == 0:
            cache_time, site_list = websites_get_list(_database_connect())

        for website in random.sample(site_list, k=len(site_list)):
            with _database_connect() as conn:
                website_cache_status(conn, website)

            time.sleep(30)

@bottle.route('/static/<path:path>')
def site_static(path):
    print('./static/{}'.format(path))
    return bottle.static_file(path, root='./static/')

@bottle.route('/')
def site_index():
    result = OrderedDict()

    with _database_connect() as conn:
        with closing(conn.cursor()) as cur:
            cur.execute('''
                        SELECT * FROM category ORDER BY category_id
                        ''')
                    
            
            for cat in map(dict, cur.fetchall()):
                result[cat['category_id']] = dict(cat, website_list=tuple())

            cur.execute('''
                        SELECT  cache.*, website.*
                        FROM    status_cache cache
                        JOIN    (SELECT     website_uri, MAX(ctime) AS ctime
                                 FROM       status_cache
                                 GROUP BY   website_uri) max
                        USING   (website_uri, ctime)
                        JOIN    website
                        USING   (website_uri)
                        ''')
            
            for site in cur.fetchall():
                result[site['category_id']]['website_list'] = result[site['category_id']]['website_list'] + (dict(site, content=ujson.loads(site['content'])), )

    return bottle.template('./templates/index.phtml', output=result)

def _database_connect():
    conn = sqlite3.connect(os.environ.get('APP_DB', './db/database.db'))
    conn.execute('pragma journal_mode=wal')
    conn.row_factory = sqlite3.Row

    return conn

def website_cache_status(conn, website):
    if not website_is_cached(conn, website):
        logging.info('Fetching status for {}'.format(website['website_uri']))
        response = requests.get(
            'https://api.ooni.io/api/v1/measurements',
            params={'probe_cc': website['country'],
                    'input': website['search_input']})
        _result = response.json()

        if _result['results']:
            with closing(conn.cursor()) as cur:
                logging.info('Caching status for {}'.format(website['website_uri']))
                cur.execute('''
                            INSERT
                            INTO    status_cache(website_uri, content, ctime)
                            VALUES  (?, JSON(?), ?)
                            ''',
                            (website['website_uri'],
                             ujson.dumps(_result),
                             int(time.time())))

            conn.commit()

def websites_get_list(conn):
    result = tuple()

    with conn:
        with closing(conn.cursor()) as cur:
            logger.info('Querying list of sites')
            cur.execute('''
                        SELECT      *
                        FROM        website
                        ''')
            
            return (time.time(), cur.fetchall())

    return result

def website_is_cached(conn, website):
    with closing(conn.cursor()) as cur:
        logging.info('Fetching cache status for {}'.format(website['website_uri']))
        cur.execute('''SELECT EXISTS(
                           SELECT   website_uri
                           FROM     status_cache
                           WHERE    website_uri = ?
                                    AND ctime > ?) AS result''',
                    (website['website_uri'],
                     int(time.time()) - 300))

        return bool(cur.fetchone()['result'])
    

if __name__ == '__main__':
    background_task = Process(target=cache_updater)
    background_task.start()

    bottle.run(port=os.environ.get('APP_PORT', 80),
               host='0.0.0.0',
               debug=True)

    background_task.terminate()