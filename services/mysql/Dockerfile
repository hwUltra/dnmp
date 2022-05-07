ARG MYSQL_VERSION
FROM ${MYSQL_VERSION}

ARG TZ

RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone

