FROM alpine:3.8
RUN apk --update --no-cache add \
	python3 \
	redis \
    postgresql-dev gcc python3-dev musl-dev
    

COPY requirements.txt /
RUN pip3 install -r /requirements.txt

RUN apk del gcc python3-dev musl-dev

COPY . /ream/

CMD ["python3", "/ream/ream.py"]

