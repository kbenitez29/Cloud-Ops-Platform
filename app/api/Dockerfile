# Alpine keeps the image small (~50MB vs ~300MB for full Node image)
FROM node:20-alpine

WORKDIR /app

# No package.json needed — we only use Node's built-in http module
COPY server.js .

EXPOSE 3000

CMD ["node", "server.js"]