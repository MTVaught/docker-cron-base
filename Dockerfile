FROM alpine:latest

RUN apk update \
    && apk add \
        bash \
        tzdata

COPY base-scripts /base-scripts

ENV MY_USER=user
ENV MY_GROUP=mygroup

ENTRYPOINT ["sh", "/base-scripts/entrypoint.sh"]

#CMD ["su", "-c", "bash", "-l", "user"];
CMD ["crond", "-f" , "-d", "8", "> /proc/1/fd/1", "2> /proc/1/fd/2"]
