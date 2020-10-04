# gradle-docker-download
A way to download and collect gradle dependencies in a docker file

Run CreateDockerRunList.sh GRADLE_ID, such as org.springframework.boot:spring-boot-dependencies:2.3.4.RELEASE, the output will be all the dependencies required for the ID provided.

Paste the results into the Dockerfile

On creation the image will only have the files in it
