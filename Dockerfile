FROM maven:3.5.2-jdk-8-alpine AS MAVEN_BUILD

MAINTAINER prabhat Ranjan

COPY pom.xml /build/
COPY src /build/src/

WORKDIR /build/
RUN mvn package

FROM openjdk:8-jre-alpine

WORKDIR /app

COPY --from=MAVEN_BUILD /build/target/docker-boot-intro-0.9.0.jar /app/

ENTRYPOINT ["java", "-jar", "docker-boot-intro-0.9.0.jar"]
