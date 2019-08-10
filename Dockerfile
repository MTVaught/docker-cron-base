FROM alpine:latest

RUN apk update \
    && apk add \
        bash

COPY base-scripts /base-scripts

ENTRYPOINT ["sh", "/base-scripts/entrypoint.sh"]

#CMD ["su", "-c", "bash", "-l", "user"];
CMD ["crond", "-f" , "-d", "8", "> /proc/1/fd/1", "2> /proc/1/fd/2"]
