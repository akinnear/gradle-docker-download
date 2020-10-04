FROM gradle:5.6.4 as gradle

USER root
WORKDIR /gradle

ADD CopyDeps.gradle /gradle
ADD DownloadSingleDep.sh /gradle
ADD template.gradle /gradle


RUN ["chmod", "+x", "/gradle/DownloadSingleDep.sh"]
RUN  PASTE_OUTPUT+HERE" \
    && gradle --build-file=CopyDeps.gradle --stacktrace --gradle-user-home=/gradle/home cacheToLocalDir

FROM scratch
COPY --from=gradle /gradle/final /