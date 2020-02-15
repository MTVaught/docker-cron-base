FROM alpine:latest

RUN apk update \
    && apk add \
        bash \
        tzdata \
        util-linux

COPY base-scripts /base-scripts

ENV APP_USER=user
ENV APP_GROUP=mygroup
ENV APP_UMASK=0000
ENV APP_RUN_WRAPPER_SCRIPT="/base-scripts/run.sh"
ENV APP_STAGING_DIR=/root/staging

ENTRYPOINT ["bash", "/base-scripts/entrypoint.sh"]

#CMD ["bash" , "-l"] # root debugging
#CMD ["su", "-c", "bash", "-l", "user"]; # user debugging
CMD ["crond", "-f" , "-d", "8", "> /proc/1/fd/1", "2> /proc/1/fd/2"]
