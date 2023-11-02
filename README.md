# Opinionated Python Starter with Poetry

This is an opinionated mini-guide to setting up a new Python project, mainly based around using [Poetry](https://python-poetry.org/).

It is intended to be followed step-by-step, rather than cloning this repository or using a cookie-cutter type tool. This way, you are free to add or skip steps with complete clarity on what is actually being installed.

## 0. Setup a Python installation

I generally use [pyenv](https://github.com/pyenv/pyenv) but I will leave that discussion for another guide. :)

## 1. Setup a new poetry project

```
$ poetry new project_name
$ cd project_name
```
In the committed repository guide I have used `opinionated-starter` but will use `project_name` in these instructions which you can replace.

Poetry [generates a file called pyproject.toml](https://python-poetry.org/docs/pyproject#the-pyprojecttoml-file) which you should edit as needed.

I won't try and introduce Poetry, their documentation will do that best.

Don't forget:
```
$ git init
```

## 2. Add .gitignore

[Github maintain a nice python .gitignore default](https://github.com/github/gitignore/blob/main/Python.gitignore), so copy and paste it. I won't copy it here as that is another place to keep it up to date.

You can also the `.ruff_cache` folder in anticipation of a later step, and any extras you need:
```
.ruff_cache
**/.DS_Store
.vscode
```

## 3. Add some development dependencies

```
$ poetry add black ruff mypy --group dev
```

I now can't really live without [black](https://github.com/psf/black) to format my Python code.

[Ruff](https://github.com/astral-sh/ruff) is a great Python linter that can help with a whole bunch of stuff and replaces a range of dependencies that people install to deal with linting.

I have also added [mypy](https://github.com/python/mypy) to do static type checking. Again, I defer to mypy's documentation for a proper introduction, but it has saved me from shipping bugs more than once, so I like to use it (within reason).

Add them with the `--group dev` flag allows them to be excluded from production deployed code.

Ruff is very configurable for different rule sets and levels of strictness. I mostly recommend sticking with the defaults and adding rule sets as you need.

You can run ruff from a terminal and customise the rule sets using flags, but it will also pick up a configuration from your `pyproject.toml`.

I like to add the `I` ruleset which enforces (and fixes for you!) sorted imports. The `N` ruleset enforces more consistent (PEP8) naming conventions - it is entirely optional. `E` and `F` are on by default.

Add this to your `pyproject.toml` to configure ruff:
```
[tool.ruff]
select = ["E", "F", "I", "N"]
```

## 4. Automate development tasks

I like to automate all the tooling for development, so I can run them as frequently as possible very easily.

There are a few different ways to do this but the nicest I have found so far when building a project with Poetry is called [Poe](https://github.com/nat-n/poethepoet).

There are a few options for installing poe (see the docs). You can install it globally using `pipx` or `pip` and then run it using `poe` in your terminal.

Or you can install it *within* this project, and you can use `poe` in your terminal if you have this project's virtual environment activated (`poetry shell`), or using poetry to execute it inside the environemnt with `poetry run poe`.

Let's install it inside this project (but you might prefer to do it globally):
```
$ poetry add poethepoet --group dev
```

The nice thing about poe (and similar tools) is that you define your tasks inside your `pyproject.toml`.

These tasks might be formatting (with black), linting, running tests etc.

Poe has a few different ways to define tasks, but here is a starter. This is the most complex way to define tasks but gives us control. Add this snippet to `pyproject.toml`:
```
[tool.poe.tasks.format]
sequence = ["black .", "ruff --select I --fix ."]
help = "Format all code with black and sort imports with ruff"
default_item_type = "cmd"

[tool.poe.tasks.lint]
sequence = ["ruff check .", "black --check .", "mypy project_name"]
help = "Run all linting, including ruff, black (check only) and mypy"
default_item_type = "cmd"
```

Don't forget to replace `project_name` in the linting task with the name of your package. This command runs mypy just on your source code (and not the tests folder).

This setup defines two tasks, `format` and `lint`. You might add another one such as `test`.

We can get poe to list them for us to check they're defined properly:
```
$ poetry run poe -h
```

Then when you have the virtual environment activated (or with poe installed globally), you can run `poe format` and your code will be formatted by black and imports sorted all in one go.

## 5. Add Dockerfile for deployment such as a web server (Optional)

There are a variety of different ways to deploy code for a project. This example is setting up a Docker image, assuming this Python project is going to be a web server or CLI tool. This doesn't include how you could package up this code and share it as a Python package (but Poetry can help with that).

The Dockerfile below builds a fairly minimal production image, without Poetry and dev dependencies, using a multi-stage Docker build. Your use case might involve a dev container for running tests etc, which you could add as another stage in the build process.

This is not a one-size-fits-all Dockerfile, you may need additional security requirements or dependencies depending on your use case.

We start with a small temporary image to work out what production dependencies we need to install. Poetry sorts that for us.

```
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
```

Now we have an image, with a `/tmp/requirements.txt` we can use to install our production dependencies, in a new image.

```
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

CMD ["python -m project_name"]
```

The full Dockerfile is in the repository.

We also need to add a `.dockerignore`. Take a look at the one committed to this repo. Don't forget to ignore the `Dockerfile` so you don't bust the cache when changing your Dockerfile repeatedly, and `.git`.
