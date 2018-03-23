FROM alpine:latest

# Base system deps
RUN apk --update add alpine-sdk \
					 python3 \
					 postgresql-client \
					 python3-dev 

# TODO: this needs to be in the nginx container :(
# COPY --chown=nginx:nginx quince/dist/ /quince/

COPY quince/server/ /app/
RUN pip3 install -r /app/requirements.txt

VOLUME ["/home/posda/cache"]

CMD ["python3", "/app/server.py"]
