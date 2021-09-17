FROM amazon/aws-sam-cli-build-image-python3.9

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -
ENV PATH "$PATH:/root/.local/bin"

COPY sam_build.sh /sam_build.sh

CMD /sam_build.sh
