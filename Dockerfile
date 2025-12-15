FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files and install ALL dependencies (including dev dependencies for build)
COPY package*.json ./
RUN npm install --legacy-peer-deps --ignore-scripts

# Copy source code, generate client, and build
COPY . .
RUN npm run generate
RUN npm run build

# Production stage - clean image with only production dependencies
FROM node:20-alpine

WORKDIR /app

# Copy package files and install only production dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps --omit=dev --ignore-scripts

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src/endpoints.json ./src/endpoints.json
COPY --from=builder /app/src/generated ./src/generated

# Expose the HTTP port
EXPOSE 3000

ENTRYPOINT ["node", "dist/index.js"]
CMD ["--http", "3000"]
