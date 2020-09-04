FROM linuxbrew/brew:2.4.16

RUN brew install groff
RUN brew install libyaml
RUN brew install python@3.7
RUN brew install python@3.8

RUN brew install zip
RUN brew install awscli

RUN brew tap aws/tap
RUN brew install aws-sam-cli

COPY sam_build.sh /sam_build.sh

CMD /sam_build.sh
