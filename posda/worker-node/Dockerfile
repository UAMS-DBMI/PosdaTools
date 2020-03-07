FROM tcia/posda:latest

COPY worker-app/requirements.txt /worker-requirements.txt
RUN pip3 install --user -r /worker-requirements.txt


COPY worker-app /worker

ENV REDIS_HOST localhost

EXPOSE 80

WORKDIR "/worker"
ENTRYPOINT ["/worker/start_worker_node.sh"]
CMD ["none"]
