# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-my-new-microservice"
LABEL REPO="https://github.com/lacion/my-new-microservice"

ENV PROJPATH=/go/src/github.com/lacion/my-new-microservice

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/lacion/my-new-microservice
WORKDIR /go/src/github.com/lacion/my-new-microservice

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/lacion/my-new-microservice"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/my-new-microservice/bin

WORKDIR /opt/my-new-microservice/bin

COPY --from=build-stage /go/src/github.com/lacion/my-new-microservice/bin/my-new-microservice /opt/my-new-microservice/bin/
RUN chmod +x /opt/my-new-microservice/bin/my-new-microservice

# Create appuser
RUN adduser -D -g '' my-new-microservice
USER my-new-microservice

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/my-new-microservice/bin/my-new-microservice"]
