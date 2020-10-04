FROM gradle:5.6.4 as gradle

USER root
WORKDIR /gradle

ADD CopyDeps.gradle /gradle
ADD DownloadSingleDep.sh /gradle
ADD template.gradle /gradle


RUN ["chmod", "+x", "/gradle/DownloadSingleDep.sh"]
RUN  /gradle/DownloadSingleDep.sh "org.apache.commons:commons-math3:3.6.1" \
  && /gradle/DownloadSingleDep.sh "com.opencsv:opencsv:5.2" \
  && /gradle/DownloadSingleDep.sh "org.apache.commons:commons-lang3:3.11" \
  && /gradle/DownloadSingleDep.sh "gradle.plugin.com.avast.gradle:gradle-docker-compose-plugin:0.12.1" \
  && /gradle/DownloadSingleDep.sh "io.spring.gradle:dependency-management-plugin:1.0.10.RELEASE" \
  && /gradle/DownloadSingleDep.sh "org.springframework.boot:spring-boot-gradle-plugin:2.3.4.RELEASE" \
  && /gradle/DownloadSingleDep.sh "io.freefair.gradle:lombok-plugin:5.2.1" \
  && /gradle/DownloadSingleDep.sh "org.unbroken-dome.gradle-plugins:gradle-testsets-plugin:3.0.1" \
  && /gradle/DownloadSingleDep.sh "pl.allegro.tech.build:axion-release-plugin:1.10.3" \
  && /gradle/DownloadSingleDep.sh "gradle.plugin.com.google.cloud.tools:jib-gradle-plugin:2.5.0" \
  && /gradle/DownloadSingleDep.sh "org.snakeyaml:snakeyaml-engine:2.1" \
  && /gradle/DownloadSingleDep.sh "com.google.cloud.tools:jib-core:0.15.0" \
  && /gradle/DownloadSingleDep.sh "junit:junit:4.12" \
  && /gradle/DownloadSingleDep.sh "net.logstash.logback:logstash-logback-encoder:6.4" \
  && /gradle/DownloadSingleDep.sh "org.influxdb:influxdb-java:2.19" \
  && /gradle/DownloadSingleDep.sh "org.awaitility:awaitility:4.0.3" \
  && /gradle/DownloadSingleDep.sh "org.awaitility:awaitility:4.0.3" \
  && /gradle/DownloadSingleDep.sh "com.playtika.testcontainers:embedded-rabbitmq:1:82" \
  && /gradle/DownloadSingleDep.sh "com.playtika.testcontainers:embedded-influxdb:1:82" \
  && /gradle/DownloadSingleDep.sh "com.playtika.testcontainers:embedded-mongodb:1:82" \
  && /gradle/DownloadSingleDep.sh "com.playtika.testcontainers:embedded-mongodb:1:82" \
  && /gradle/DownloadSingleDep.sh "com.playtika.testcontainers:embedded-rabbitmq:1:82" \
  && /gradle/DownloadSingleDep.sh "org.awaitility:awaitility:4.0.3" \
  && /gradle/DownloadSingleDep.sh "com.playtika.testcontainers:embedded-mongodb:1:82" \
  && /gradle/DownloadSingleDep.sh "com.playtika.testcontainers:embedded-rabbitmq:1:82" \
  && /gradle/DownloadSingleDep.sh "org.awaitility:awaitility:4.0.3" \
  && /gradle/DownloadSingleDep.sh "org.slf4j:slf4j-api:1.7.30" \
  && /gradle/DownloadSingleDep.sh "org.apache.commons:commons-math3:3.6.1" \
  && /gradle/DownloadSingleDep.sh "org.awaitility:awaitility:4.0.3" \
  && /gradle/DownloadSingleDep.sh "org.apache.commons:commons-math3:3.6.1" \
  && /gradle/DownloadSingleDep.sh "org.bytedeco:gsl-platform:2.6-1.5.4" \
  && /gradle/DownloadSingleDep.sh "com.github.node-gradle:gradle-node-plugin:2.2.4" \
    && gradle --build-file=CopyDeps.gradle --stacktrace --gradle-user-home=/gradle/home cacheToLocalDir

FROM scratch
COPY --from=gradle /gradle/final /