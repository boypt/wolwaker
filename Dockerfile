FROM node:10-alpine

RUN echo -e "https://mirrors.ustc.edu.cn/alpine/latest-stable/main\nhttps://mirrors.ustc.edu.cn/alpine/latest-stable/community" > /etc/apk/repositories \
    && apk add --no-cache git tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && git clone https://github.com/pentie/wolwaker.git /src/wolwaker \
    && cd /src/wolwaker/web  \
    && npm install

ENV DEBUG=web:* NODE_ENV=production ADDRESS=0.0.0.0 PORT=3100
EXPOSE 3100
WORKDIR /src/wolwaker/web
CMD [ "node", "bin/www" ]

