# Stage 1 — Flutter web build
FROM debian:stable-slim AS build

RUN apt-get update && apt-get install -y \
    curl git wget unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_HOME=/opt/flutter
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 $FLUTTER_HOME
ENV PATH="$FLUTTER_HOME/bin:$PATH"
RUN flutter config --enable-web && flutter precache

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --dart-define=API_URL=http://localhost:3000/api

# Stage 2 — nginx serve
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
