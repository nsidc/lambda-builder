FROM linuxbrew/brew:2.4.16

RUN brew install groff
RUN brew install libyaml
RUN brew install python@3.9

RUN brew install zip
RUN brew install awscli

RUN brew tap aws/tap
RUN brew install aws-sam-cli

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -
ENV PATH "$PATH:/root/.local/bin"

COPY sam_build.sh /sam_build.sh

CMD /sam_build.sh
