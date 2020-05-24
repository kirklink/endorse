FROM google/dart:2 AS build

COPY . /app
WORKDIR /app
RUN pub get
WORKDIR /
RUN mkdir build && dart2native app/bin/main.dart -o build/dart_app



FROM gcr.io/distroless/base-debian10:nonroot

ENV ARROW_ENVIRONMENT production
COPY --from=build build/dart_app /

CMD [ "/dart_app" ]