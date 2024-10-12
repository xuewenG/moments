FROM node:22.2.0-alpine AS front
WORKDIR /app
RUN npm install -g pnpm
COPY front/package.json .
COPY front/pnpm-lock.yaml .
RUN pnpm install
COPY front/. .
RUN pnpm run generate

FROM golang:1.22.5-alpine AS backend
WORKDIR /app
ENV CGO_ENABLED=1
RUN apk add --no-cache build-base tzdata
COPY backend/go.mod .
COPY backend/go.sum .
RUN go mod download
COPY backend/. .
COPY --from=front /app/.output/public /app/public
RUN go build -tags prod -ldflags="-s -w" -o /app/moments

FROM alpine
WORKDIR /app/data
RUN apk update --no-cache && apk add --no-cache ca-certificates tzdata
ARG VERSION
ENV PORT=3000
ENV TZ=Asia/Shanghai
ENV VERSION=$VERSION
COPY --from=backend /app/moments /app/moments
RUN chmod +x /app/moments
EXPOSE 3000
CMD ["/app/moments"]
