# ---------- Stage 1: build WASM engine + fetch Freedoom IWADs ----------
FROM emscripten/emsdk:3.1.51 AS engine
RUN apt-get update && apt-get install -y \
    git curl unzip python3 make cmake autoconf automake libtool pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth=1 https://github.com/cloudflare/doom-wasm.git
WORKDIR /src/doom-wasm

# Freedoom Phase 1 & 2 as doom1.wad / doom2.wad
RUN curl -L -o /tmp/freedoom.zip https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip \
    && unzip /tmp/freedoom.zip -d /tmp/freedoom \
    && cp /tmp/freedoom/freedoom-0.12.1/freedoom1.wad ./src/doom1.wad \
    && cp /tmp/freedoom/freedoom-0.12.1/freedoom2.wad ./src/doom2.wad

# build wasm engine
RUN chmod +x ./scripts/build.sh && ./scripts/build.sh
# output is in /src/doom-wasm/build/

# ---------- Stage 2: build React app ----------
FROM node:20-alpine AS web
WORKDIR /app

# deps first for better caching
COPY package*.json ./
RUN npm ci || npm i

# app source
COPY . .

# bring engine artifacts into public/engine so Vite serves them from /engine
RUN mkdir -p public/engine
COPY --from=engine /src/doom-wasm/build/ /retro-arcade/public/engine/

# build Vite app
RUN npm run build

# ---------- Stage 3: serve static site with nginx ----------
FROM nginx:alpine

# copy build output
COPY --from=web /app/dist/ /usr/share/nginx/html/

# ensure nginx serves .wasm with correct MIME type
RUN printf "\n\
    types {\n\
    application/wasm wasm;\n\
    }\n" > /etc/nginx/conf.d/wasm.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
