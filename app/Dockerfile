# Simple Dockerfile for running the server
FROM dart:stable as app
WORKDIR /app
COPY pubspec.yaml .
RUN dart pub get
COPY . .
RUN dart pub get --offline
EXPOSE 8080
ENV PORT=8080
CMD ["dart", "run", "bin/server.dart"]
