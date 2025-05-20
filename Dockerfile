FROM maven:3.9.9-amazoncorretto-21-al2023 AS build-env
WORKDIR /usr/local/kinesis_scaling

COPY pom.xml .
RUN mvn dependency:go-offline
COPY . .

RUN  mvn clean package assembly:assembly

FROM amazoncorretto:21-al2023-headless
WORKDIR /usr/local/kinesis_scaling
COPY --from=build-env /usr/local/kinesis_scaling/target/KinesisScalingUtils-.9.8.8-complete.jar ./KinesisScalingUtils-.9.8.8-complete.jar
COPY ./conf/configuration.json ./conf/
ENTRYPOINT [ \
    "java", \
    "-Dconfig-file-url=/usr/local/kinesis_scaling/conf/configuration.json", \
    "-cp", \
    "/usr/local/kinesis_scaling/KinesisScalingUtils-.9.8.8-complete.jar", \
    "com.amazonaws.services.kinesis.scaling.auto.AutoscalingController" \
]
