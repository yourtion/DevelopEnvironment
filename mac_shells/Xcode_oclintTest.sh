#!/bin/sh

# Check if xctool and oclint are installed
if ! which -s xctool
then
  echo 'error: xctool not found, install e.g. with homebrew'
  exit 1
fi

if ! which -s oclint-json-compilation-database
then
  echo 'error: OCLint not installed, install e.g. with homebrew cask'
  exit 2
fi

# Setup File dir
project=$1
scheme=$2

if [ $# = "1" ]; then
  scheme=$project; 
fi

echo "Test $scheme in $project"
# Cleanup before building
rm -f compile_commands.json
xctool -project $project.xcodeproj -scheme $scheme clean > /dev/null
echo "-> Cleanup Done"

# Build Project
xctool build \
  -project $project.xcodeproj -scheme $scheme \
  -reporter json-compilation-database:compile_commands.json
echo "-> Build Project Done \n\nResult:"

# Analyze Project
oclint-json-compilation-database -e Pods -- \
  -max-priority-1=100000 \
  -max-priority-2=100000 \
  -max-priority-3=100000 \
  -disable-rule=InvertedLogic \
  -disable-rule=CollapsibleIfStatements \
  -disable-rule=UnusedMethodParameter \
  -disable-rule=LongLine \
  -disable-rule=LongVariableName \
  -disable-rule=ShortVariableName \
  -disable-rule=UselessParentheses \
  -disable-rule=IvarAssignmentOutsideAccessorsOrInit | sed 's/\(.*\.\m\{1,2\}:[0-9]*:[0-9]*:\)/\1 warning:/'

# Final cleanup
rm -f compile_commands.json
