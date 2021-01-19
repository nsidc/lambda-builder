FROM maven.earthdata.nasa.gov/aws-sam-cli-build-image-python3.8

COPY sam_build.sh /sam_build.sh

CMD /sam_build.sh
