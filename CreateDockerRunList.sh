#!/bin/bash

if [[ $# -ne 1 ]]; then 
    echo "script.sh BOM_ID"
    echo "EXAMPLE org.springframework.boot:spring-boot-dependencies:2.3.4.RELEASE"
    exit 2
fi

function downloadDependency() {
    echo "  && /gradle/DownloadSingleDep.sh \"$1\" \\"
}

function downloadBomDependency() {
    IFS=':' read -r -a splitDependency <<< "$1"
    IFS='.' read -r -a splitGroup <<< "${splitDependency[0]}"
    IFS='/' eval 'groupUrl="${splitGroup[*]}"'
    local groupId=${splitDependency[0]}
    local name=${splitDependency[1]}
    local version=${splitDependency[2]}
    local url="https://repo1.maven.org/maven2/${groupUrl}/${name}/${version}/${name}-${version}.pom"
    local bomFileName="${name}-${version}.pom"
    wget -q $url -O "$bomFileName"

    local depsFile="${name}-${version}.deps"

    if grep -q \<properties\> "$bomFileName"; then
        # Change the first set of propertey numbers specified by ${id}
        eval "sed `sed -n -e "s/\///g" -e "/<properties>/,/<\/properties>/s/ *<\([^>]*\)>\([^<]*\)<.*$/-e 's\/\\\\$\\{\1\\}\/\2\/' /p" ${bomFileName} | tr -d '\n'` ${bomFileName}" > tmp1.bom

        # Some properties can be transative like ${id} which does not get caught in the first round of replacing, do it 1 more time
        eval "sed `sed -n -e "s/\///g" -e "/<properties>/,/<\/properties>/s/ *<\([^>]*\)>\([^<]*\)<.*$/-e 's\/\\\\$\\{\1\\}\/\2\/' /p" tmp1.bom | tr -d '\n'` tmp1.bom" > tmp.bom

        rm tmp1.bom
    else
        cp ${bomFileName} tmp.bom
    fi


    cat tmp.bom |
        sed -n \
            -e "s/\${awsjavasdk.version}/${version}/g" \
            -e "s/\${project.version}/${version}/g" \
            -e "s/\${project.groupId}/${groupId}/g" \
            -e '/<classifier>/,/<\/classifier>/d' \
            -e '/<optional>/,/<\/optional>/d' \
            -e '/<exclusions>/,/<\/exclusions>/d' \
            -e '/<dependencies>/,/<\/dependencies>/p' |
        tr -d '\n\t ' | \
        sed \
            -e 's/<scope>[^<]*<\/scope>//g' \
            -e 's/<!--[^>]*>//g' \
            -e 's/<dependencies>//g' \
            -e 's/<\/dependencies>//g' \
            -e 's/<\/dependency>/<\/dependency>\n/g' \
            -e 's/<dependency><groupId>\([^<]*\)<\/groupId><artifactId>\([^<]*\)<\/artifactId><version>\([^<]*\)<\/version><\/dependency>/\1:\2\:\3/g' \
            -e 's/<dependency><artifactId>\([^<]*\)<\/artifactId><groupId>\([^<]*\)<\/groupId><version>\([^<]*\)<\/version><\/dependency>/\2:\1\:\3/g' > $depsFile

    rm tmp.bom

    downloadDependency "$1" $2

    while read dependency; do
        local isPom=false
        if [[ $dependency =~ \<dependency\>.*\<type\>.* ]] ;
        then
            if [[ $dependency =~ \<type\>pom\<\/type\>.* ]] ;
            then
                isPom=true
            fi

            dependency="$(echo "${dependency}" | sed -e 's/<dependency><groupId>\([^<]*\)<\/groupId><artifactId>\([^<]*\)<\/artifactId><version>\([^<]*\)<\/version><type>\([^<]*\)<\/type><\/dependency>/\1:\2\:\3/g')"
        fi

        if [[ "$isPom" = true ]] ;
        then
            downloadBomDependency "$dependency" $(expr $2 + 1)
        else
            downloadDependency "$dependency" $2
        fi
    done < $depsFile

    rm $depsFile
    rm $bomFileName
}

downloadBomDependency "$1" 0