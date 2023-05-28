FROM python:3.9-buster

RUN mkdir /app && python -m pip install pipenv

WORKDIR /app

ADD Pipfile /app/Pipfile
ADD Pipfile.lock /app/Pipfile.lock

RUN pipenv install

ADD main.py /app/main.py
ARG DATABASE_URL=postgres://postgres:postgres@db:5432/news
ENV DATABASE_URL="${DATABASE_URL}"
CMD pipenv run uvicorn main:app --reload --host 0.0.0.0 --port 9000

EXPOSE 9000
