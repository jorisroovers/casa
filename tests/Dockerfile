FROM alpine:3.9
RUN apk add python3
ADD . /opt/casa-tests
RUN pip3 install -r /opt/casa-tests/test-requirements.txt
WORKDIR /opt/casa-tests
