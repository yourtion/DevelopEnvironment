#!/bin/bash
#
# Author: YourtionGuo <yourtion@gmail.com>
#

CHANGELOG_FILE=CHANGELOG.md
FORMAT="- %s"

if test "$CHANGELOG_FILE" != ""; then
  rm -rf $CHANGELOG_FILE
  touch $CHANGELOG_FILE
fi

echo "CHANGELOG" >> $CHANGELOG_FILE
echo "=========" >> $CHANGELOG_FILE

git for-each-ref --sort='*authordate' --format="%(refname:short)" refs/tags | grep -v '^$' | tail -r | while read TAG ; do
    if [ $NEXT ];then
        echo >> $CHANGELOG_FILE
        echo *$NEXT* >> $CHANGELOG_FILE
        echo '---' >> $CHANGELOG_FILE
    fi

    echo >> $CHANGELOG_FILE
    GIT_PAGER=cat git log --no-merges --date=short --pretty=format:"$FORMAT" $TAG..$NEXT >> $CHANGELOG_FILE
    echo >> $CHANGELOG_FILE
    NEXT=$TAG
done

echo >> $CHANGELOG_FILE
FIRST=$(git tag -l | head -1)
echo *$FIRST* >> $CHANGELOG_FILE
echo '---' >> $CHANGELOG_FILE
echo >> $CHANGELOG_FILE
GIT_PAGER=cat git log --no-merges --date=short --pretty=format:"$FORMAT" $FIRST >> $CHANGELOG_FILE
echo >> $CHANGELOG_FILE
