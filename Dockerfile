FROM homebrew/brew:2.2.17

RUN brew tap aws/tap && \
    brew install aws-sam-cli zip

RUN brew install awscli

COPY sam_build.sh /sam_build.sh

CMD /sam_build.sh
