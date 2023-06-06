FROM amazon/aws-sam-cli-build-image-python3.8

RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH "$PATH:/root/.local/bin"

COPY sam_build.sh /sam_build.sh

CMD /sam_build.sh
