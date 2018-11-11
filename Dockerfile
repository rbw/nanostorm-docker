FROM alpine:3.8

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN apk add --no-cache git
RUN apk add --no-cache gcc python3-dev musl-dev autoconf automake libtool make

EXPOSE 5000

RUN mkdir -p /app/logs /tmp/libb2

RUN git clone https://github.com/BLAKE2/libb2 /tmp/libb2

WORKDIR /tmp/libb2
RUN ./autogen.sh && ./configure && make install

WORKDIR /app

COPY ./nanostorm /app/nanostorm
COPY requirements.txt /app/requirements.txt
COPY ./examples/settings /app/settings
RUN pip3 install --no-cache-dir -r /app/requirements.txt


ENTRYPOINT ["python3", "-m", "nanostorm"]
