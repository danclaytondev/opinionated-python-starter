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
