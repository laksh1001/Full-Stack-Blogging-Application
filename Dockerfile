FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

# Copy the exact artifact name or copy into the folder
COPY target/Blogging-application-0.0.3.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
