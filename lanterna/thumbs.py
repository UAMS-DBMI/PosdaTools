#!/usr/bin/python3 -u
import redis
import subprocess
import os

REDIS_HOST=os.environ['POSDA_REDIS_HOST']


def main():

    redis_db = redis.StrictRedis(host=REDIS_HOST, db=0)


    while True:
        sr = redis_db.brpop("thumbnails_required", 5)

        if sr is None:
            continue


        _, filename = sr
        print(filename)

        subprocess.run(["dcm2jpg",
                        filename,
                        f"{filename.decode()}[512;512;-1][0].jpeg"])



if __name__ == "__main__":
    print("thumbs, a lightweight thumbnail generator")
    main()
