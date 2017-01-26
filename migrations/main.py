#!/usr/bin/env python3

import sys
import os

import psycopg2

import config

class MigrationFailedError(Exception):
    pass

def init():
    # make dirs for each target
    # make plan files for each target

    for target in config.targets:
        try:
            os.mkdir(target)
        except FileExistsError:
            pass
        plan_filename = os.path.join(target, f"{target}.plan")

        # create the files if they don't already exist
        with open(plan_filename, 'a'):
            pass

def get_local_version(plan_file):
  # currently just count the lines in the file
  return len(plan_file)

def load_plan(plan_filename):
    plan = []
    with open(plan_filename) as f:
        for line in f:
            plan.append(line.strip())

    return plan

def apply(script, conn, env, target, new_version):
    print(f"applying: {script}") # apply migration here
    cur = conn.cursor()

    with open(f"{target}/{script}.sql") as plan_file:
        plan = plan_file.read()

    try:
        cur.execute(plan)
    except Exception as e:
        print("Failed to apply migration! Possibly already applied? Error was:")
        print(e.pgerror)
        raise MigrationFailedError()

    print(f"Updating db version to {new_version}")
    cur.execute(f"update db_version.version set version = {new_version}")
    conn.commit()

# human range; range starting at 1 instead of 0
def hrange(x):
    return range(1, x + 1)

def initalize_db(conn):
    cur = conn.cursor()
    print("Adding version table to database...")
    cur.execute("create schema db_version")
    cur.execute("create table db_version.version (version integer)")
    cur.execute("insert into db_version.version values (0)")
    conn.commit()

def get_remote_version(conn):
    cur = conn.cursor()
    try:
        cur.execute("select version from db_version.version")
    except psycopg2.ProgrammingError as e:
        if e.pgcode == '42P01':
            conn.rollback()
            initalize_db(conn)
            return 0
        else:
            raise

    return cur.fetchone()[0]

def process_one(env, target):
    print(f"\nApplying migrations to target: {target}")
    plan = load_plan(os.path.join(target, f"{target}.plan"))
    conn = psycopg2.connect(f"dbname={target} host={env['hostname']}")

    # determine the latest local version
    local_version = get_local_version(plan)

    # determine the latest database version
    db_version = get_remote_version(conn)

    # calculate the migration difference
    if local_version == db_version:
        print(f"{target} is up to date (plan version is {local_version}, "
              f"db version is {db_version}).")
        return
    diff = set(hrange(local_version)) - set(hrange(db_version))

    # apply those migrations
    for i, l in enumerate(plan):
        i = i + 1
        if i in diff:
            apply(l, conn, env, target, i)

    conn.close()

def migrate(env_name):
    env = config.environments[env_name]

    for t in config.targets:
        try:
            process_one(env, t)
        except MigrationFailedError:
            print(f"Skipping remaining migrations for {t}.")


def main():
    command = sys.argv[1]

    if command.lower() == 'init':
        return init()

    if command.lower() == 'migrate':
        return migrate(sys.argv[2])


if __name__ == '__main__':
    main()

