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