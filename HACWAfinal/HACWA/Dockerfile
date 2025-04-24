FROM node:19.7-alpine
RUN mkdir /app
WORKDIR /app
COPY ./web/package.json /app/
RUN npm install
COPY ./web/public /app/public
COPY ./web/src /app/src
EXPOSE 3000

CMD ["npm", "start"]
