# lambda-builder

Use
[`sam`](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html)
to build your lambda into a `lambda.zip` without installing and setting up `sam`
yourself. Handy for running in a CI environment where `docker` is available but
`sam` is not.

This runs `sam build --use-container` in order to build lambdas that require
system dependencies. For more details on this, see the [AWS
docs](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-using-build.html).

This script does not provide any capabilities with `sam local invoke` to run
your lambda locally; it merely produces a `lambda.zip` that is suitable for
uploading to AWS.

## Requirements

* Docker

## Installation

```
git clone https://github.com/nsidc/lambda-builder
```

## Usage

```
/path/to/lambda-builder/build.sh relative-or-absolute/path/to/lambda/directory
```

## Docker notes

`sam` uses Docker, and `build.sh` starts up a Docker container that runs `sam`,
and `sam` uses a Docker container for a build environment matching AWS, but this
is not Docker-in-Docker; the Docker socket is mounted so that `sam` has access
to the "host Docker".
