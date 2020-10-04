#!/bin/bash

if [[ $# -ne 1 ]]; then 
    echo "script.sh BOM_ID"
    exit 2
fi

echo "Starting Download: $1"
sed -e "s/#{DEPENDENCY}/${1}/" template.gradle >> build.gradle
# gradle --stacktrace --no-daemon --gradle-user-home=/gradle/home eclipse
gradle --stacktrace --gradle-user-home=/gradle/home eclipse
echo "Finished Download: $1"
rm build.gradle