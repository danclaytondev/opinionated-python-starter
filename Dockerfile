FROM python:3.11-slim as requirements-stage

WORKDIR /tmp

# https://python-poetry.org/docs#ci-recommendations
# We are just using poetry to export a requirements.txt so we don't need to worry about virtual environments etc.
ENV POETRY_VERSION=1.6.1
RUN pip install poetry

# By only including these, we can cache this image and only rebuild it when we change dependencies, not app code.
COPY ./pyproject.toml ./poetry.lock* /tmp/

# --without dev means poetry will ignore dependencies in the dev group (see your pyproject.toml)
RUN poetry export -f requirements.txt --output requirements.txt --without dev --without-hashes

FROM python:3.11-slim

# stop python print statements from buffering
ENV PYTHONUNBUFFERED=TRUE

WORKDIR /app

COPY --from=requirements-stage /tmp/requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY ./ /app/

# here we read a build argument for app version,
# and save into an environment variable so we can read it in app code
ARG APP_VERSION="-"
ENV APP_VERSION=$APP_VERSION

# If you are building a web app, add a port
# EXPOSE 8000

CMD ["python -m opinionated_starter"]