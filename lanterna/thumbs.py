#!/usr/bin/python3 -u
import redis
import subprocess


def main():

    redis_db = redis.StrictRedis(host="redis", db=0)


    while True:
        sr = redis_db.brpop("thumbnails_required", 5)

        if sr is None:
            continue


        _, filename = sr
        print(filename)

        subprocess.run(["convert",
                        "-define", "dcm:rescale=true",
                        "-define", "dcm:unsigned=true",
                        filename,
                        "-set", "filename:f", "%i",
                        "%[filename:f][512;512;-1][0].jpeg"])



if __name__ == "__main__":
    print("thumbs, a lightweight thumbnail generator")
    main()
