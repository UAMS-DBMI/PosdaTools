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

    all_targets = []

    # build common target list
    for env, e_details in config.t_env.items():
        all_targets.extend(e_details['targets'].keys())

    for target in set(all_targets):
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
        if e.pgcode == '42P01' or e.pgcode == '3F000':
            conn.rollback()
            initalize_db(conn)
            return 0
        else:
            print(e.pgcode)
            raise

    return cur.fetchone()[0]

def connect(target_db, hostname):
    if hostname != 'localhost':
        return psycopg2.connect(f"dbname={target_db} host={hostname}")
    else:
        return psycopg2.connect(f"dbname={target_db}")


def process_one(env, target):
    target_db = env['targets'][target]
    print(f"\nApplying migrations to target: {target} ({target_db})")
    plan = load_plan(os.path.join(target, f"{target}.plan"))
    conn = connect(target_db, env['hostname'])

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

def migrate(env_name, target=None):
    env = config.t_env[env_name]

    targets = []
    if target is None:
        targets = env['targets'].keys()
    else:
        targets = [target]

    for t in targets:
        try:
            process_one(env, t)
        except MigrationFailedError:
            print(f"Skipping remaining migrations for {t}.")

def status(env_name):
    env = config.t_env[env_name]

    for target, target_db in env['targets'].items():
        plan = load_plan(os.path.join(target, f"{target}.plan"))
        conn = connect(target_db, env['hostname'])

        local_version = get_local_version(plan)
        db_version = get_remote_version(conn)

        conn.close()

        print(f"""Target: {target} ({target_db})
Database version: {db_version}
Plan version: {local_version}
""")

def force(version, env_name, target):
    print(f"Forcing {target} to version {version}, in {env_name}")

    env = config.t_env[env_name]
    target_db = env['targets'][target]

    conn = connect(target_db, env['hostname'])
    cur = conn.cursor()

    cur.execute(f"update db_version.version set version = {version}")
    conn.commit()

    conn.close()

def main():
    if len(sys.argv) <= 1:
        print(f"Usage: {sys.argv[0]} COMMAND\n"
               "Where command is one of: init, migrate, status, force")
        return
    command = sys.argv[1]

    if command.lower() == 'init':
        return init()

    if command.lower() == 'migrate':
        return migrate(*sys.argv[2:])

    if command.lower() == 'force':
        return force(*sys.argv[2:5])

    if command.lower() == 'status':
        return status(sys.argv[2])

    print("Command not recognized!")


if __name__ == '__main__':
    main()

