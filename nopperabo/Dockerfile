###############################################################################
FROM python:3.12-slim as builder-parent

RUN pip install build
RUN apt-get update \
	&& apt-get install -y \
		git \
	&& rm -rf /var/lib/apt/lists/*

###############################################################################
FROM builder-parent as builder

ARG GIT_COMMIT
ARG SETUPTOOLS_SCM_PRETEND_VERSION=0.1.dev+g$GIT_COMMIT

COPY masker /masker
RUN rm -f /masker/.git
RUN cd /masker && python -m build

###############################################################################
FROM python:3.12-slim

COPY --from=builder /masker/dist/* /masker/

# # Install masker itself
RUN PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir /masker/*.whl

# Install nopperabo and it's deps
COPY gelf_wrapper.py start.sh pyproject.toml README.md src/nopperabo/nopperabo.py /scripts/
RUN PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir /scripts/

ENTRYPOINT ["/scripts/start.sh"]
