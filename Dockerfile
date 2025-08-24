# -------- Stage 1: Build Doom WebAssembly engine + Freedoom assets --------
FROM emscripten/emsdk:3.1.51 AS engine

RUN apt-get update && apt-get install -y \
    git curl unzip python3 make cmake autoconf automake libtool pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth=1 https://github.com/cloudflare/doom-wasm.git
WORKDIR /src/doom-wasm

# Fetch Freedoom Phase1 & 2 WADs
RUN curl -L -o /tmp/freedoom.zip https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip \
    && unzip /tmp/freedoom.zip -d /tmp/freedoom \
    && cp /tmp/freedoom/freedoom-0.12.1/freedoom1.wad ./src/doom1.wad \
    && cp /tmp/freedoom/freedoom-0.12.1/freedoom2.wad ./src/doom2.wad

# Build the WASM engine
RUN chmod +x ./scripts/build.sh && ./scripts/build.sh
# Build output is in /src/doom-wasm/build/

# -------- Stage 2: Build your React/Vite app --------
FROM node:20-alpine AS web
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci || npm i

# Copy application code
COPY . .

# Place engine files into public/engine for Vite
RUN mkdir -p public/engine
COPY --from=engine /src/doom-wasm/build/ /app/public/engine/

# Build the Vite app
RUN npm run build

# -------- Stage 3: Serve with Nginx --------
FROM nginx:alpine
COPY --from=web /app/dist/ /usr/share/nginx/html/

# Serve .wasm files with correct MIME type
RUN echo "application/wasm wasm;" >> /etc/nginx/mime.types

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
