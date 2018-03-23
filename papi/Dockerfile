FROM alpine:latest

# Base system deps
RUN apk --update add alpine-sdk \
					 python3 \
					 python3-dev \
					 postgresql-client
					 # file 
					 # tzdata
					 # wget 

# Copy just the requirements in first, so we don't have to reinstall
# during development
COPY posda-api/requirements.txt /
RUN pip3 install -r /requirements.txt

COPY posda-api/ /app/

CMD ["python3", "/app/api-server.py"]

# EXPOSE 80
