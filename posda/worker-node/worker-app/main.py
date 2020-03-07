import os
import flask
import redis
import psycopg2

class WorkerNode:
    def __init__(self):
        self.config = self.get_config()
        self.redis_conn = self.get_redis_connection()
        self.db_conn = self.get_database_connection()
        self.db_conn.autocommit = True

    def get_config(self):
        return os.environ

    def get_redis_connection(self):
        return redis.StrictRedis(
            host=self.config['REDIS_HOST'],
            db=0
        )

    def get_database_connection(self):
        return psycopg2.connect(
            database="posda_files"
        )

    def take_work(self, work_id):
        hostname = self.config['HOSTNAME']
        cur = self.db_conn.cursor()
        cur.execute("""
            update work
            set node_hostname = %s
            where work_id = %s
            returning subprocess_invocation_id
        """, [hostname, work_id])

        return cur.fetchone()[0]

    def get_invocation_details(self, invoc_id):
        cur = self.db_conn.cursor()
        cur.execute("""
            select *
            from subprocess_invocation
            where subprocess_invocation_id = %s
        """, [invoc_id])

        return cur.fetchone()


    def process(self, work_id):
        print(f"handling work_id={work_id}")

        invoc_id = self.take_work(work_id)
        print(f"invoc_id={invoc_id}")

        invoc_details = self.get_invocation_details(invoc_id)
        print(invoc_details)

    def main(self):
        while True:
            sr = self.redis_conn.brpop("work", 5)
            if sr is None:
                continue

            _, work_id = sr
            self.process(work_id.decode())
            break  #TODO remove this


if __name__ == '__main__':
    WorkerNode().main()
