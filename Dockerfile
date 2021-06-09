ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS builder

RUN apk add --no-cache gcc make musl-dev git \
	&& git clone --recurse-submodules https://github.com/michaelforney/cproc.git
WORKDIR /cproc

RUN make qbe -j$(nproc) \
	&& export PATH=$PWD/qbe/obj:$PATH \
	&& make bootstrap -j$(nproc) \
	&& make check -j$(nproc) \
	&& make install

RUN apk del git gcc make musl-dev

ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apk add --no-cache musl-dev make

COPY --from=builder /usr/local /usr/local

ENV PATH="/usr/local/bin:${PATH}"

ENV CC=/usr/local/bin/cproc

WORKDIR /usr/src/myapp

CMD ["cproc", ""]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/cproc" \
	  org.label-schema.description="build cproc compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-cproc" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/cproc -f Dockerfile ."
