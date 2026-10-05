# Alpine keeps the image small (~50MB vs ~300MB for full Node image)
FROM node:20-alpine

WORKDIR /app

COPY package.json .
RUN npm install --omit=dev
COPY server.js .

EXPOSE 3000

CMD ["node", "server.js"]