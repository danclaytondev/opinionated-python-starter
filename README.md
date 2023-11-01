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

