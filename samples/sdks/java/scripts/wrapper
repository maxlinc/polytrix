#!/bin/bash
SOURCE_FILE=$1
CLASSNAME=`basename $SOURCE_FILE .java`
#NAMESPACE=org.example.
CLASS="${NAMESPACE}${CLASSNAME}"
gradle assemble --quiet
java -classpath build/libs/java-1.0.jar $CLASS

