FROM python:3-slim

COPY Pipfile Pipfile.lock dist.py /opt/

WORKDIR /opt
RUN pip install --no-cache-dir pipenv &&\
    PIPENV_VENV_IN_PROJECT=true pipenv install

ENTRYPOINT ["/opt/.venv/bin/python"]
CMD ["/opt/dist.py"]
