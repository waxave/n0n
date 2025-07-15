FROM node:20-slim AS builder

WORKDIR /custom-nodes
COPY custom-nodes/package*.json ./
RUN npm install
COPY custom-nodes/ .
RUN npm run build

FROM n8nio/n8n:stable

COPY --from=builder /custom-nodes/dist /data/custom-nodes
