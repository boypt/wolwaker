FROM node:9-alpine

RUN apk add --no-cache git \
    && git clone https://github.com/pentie/wolwaker.git /src/wolwaker \
    && cd /src/wolwaker  \
    && npm install

ENV DEBUG=web:* NODE_ENV=production ADDRESS=0.0.0.0 PORT=3100
EXPOSE 3100
WORKDIR /src/wolwaker
CMD [ "node", "bin/www" ]


