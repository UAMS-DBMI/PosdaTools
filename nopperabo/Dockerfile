###############################################################################
FROM python:3.12-slim as builder-parent

RUN pip install build

###############################################################################
FROM builder-parent as builder

COPY masker /masker
RUN cd /masker && python -m build

###############################################################################
FROM python:3.12-slim

COPY --from=builder /masker/dist/* /masker/

# # Install masker itself
RUN PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir /masker/*.whl

# Install nopperabo and it's deps
COPY start.sh pyproject.toml README.md src/nopperabo/nopperabo.py /scripts/
RUN PYTHONDONTWRITEBYTECODE=1 pip install --no-cache-dir /scripts/

ENTRYPOINT ["/scripts/start.sh"]
