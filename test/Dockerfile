FROM mtvaught/cron-base:latest

RUN apk update \
    && apk add \
        bash

COPY startup.sh /root/staging/startup.sh
COPY run.sh /root/staging/run.sh
RUN chmod +x /root/staging/startup.sh
RUN chmod +x /root/staging/run.sh

#CMD ["su", "-c", "bash", "-l", "user"];
#CMD ["bash"];
