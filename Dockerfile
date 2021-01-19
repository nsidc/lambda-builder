# image from Docker Hub: amazon/aws-sam-cli-build-image-python3.8
ARG image=maven.earthdata.nasa.gov/aws-sam-cli-build-image-python3.8
FROM ${image}

COPY sam_build.sh /sam_build.sh

CMD /sam_build.sh
