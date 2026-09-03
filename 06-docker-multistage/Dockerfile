# Build stage: installs dependencies separately from the final runtime image.
FROM node:22-alpine AS dependencies
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

# Production stage: copies only what is required at runtime.
FROM node:22-alpine AS production
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY package.json server.js ./
USER node
EXPOSE 8080
CMD ["npm", "start"]
