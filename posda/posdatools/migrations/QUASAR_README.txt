posda_queries (and maybe others) are behind in production because currently
scripts with COPY FROM STDIN cannot function. I'm not sure if there is a way
to fix this other than calling out to psql binary instead of pure python.
