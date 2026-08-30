FROM eclipse-temurin:21-jre-alpine

# Update package index and upgrade vulnerable OpenSSL libraries
RUN apk update && apk upgrade --no-cache

WORKDIR /app
COPY target/DevSecOps-CI-CD-Pipeline-Prod-Project-1.0.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]