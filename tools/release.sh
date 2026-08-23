#!/bin/bash

# clog might be installed in the user home
export PATH="$PATH:~/.cargo/bin"

# CONTRIBUTORS
make CONTRIBUTORS > _CONTRIBUTORS
if [ ! -s _CONTRIBUTORS ]; then
    # no CONTRIBUTORS means no need to make a release
    # exit without populating new_version
    exit 0
fi

if [ -z "$1" ]; then
    LAST_VERSION=$(git describe --abbrev=0 --tags --always 2> /dev/null)
    NEW_VERSION=$(echo "$LAST_VERSION" | awk '{print ++$1}')
    if [ "$NEW_VERSION" -lt 100 ]; then
        NEW_VERSION="0$NEW_VERSION"
    fi
else
    NEW_VERSION="$1"
fi

# change current branch to release
git branch -m release

printf "#### Contributors\n\n" > CONTRIBUTORS.md
cat _CONTRIBUTORS >> CONTRIBUTORS.md

# Update AUTHORS
make AUTHORS

# Update the contributors list in NEWS.md
if ! type -p clog &> /dev/null; then
    cargo install clog-cli --version 0.9.3
fi
head --lines=2 NEWS.md > NEWS_header.md
tail --lines=+2 NEWS.md > NEWS_body.md
printf "dracut-%s\n==========\n" "$NEW_VERSION" > NEWS_header_new.md

# Append the list to the section in `NEWS.md`
cat CONTRIBUTORS.md NEWS_body.md > NEWS_body_with_conttributors.md

# Get a template with [`clog`](https://github.com/clog-tool/clog-cli)
# clog will always output both the new release and old release information together
clog -F --infile NEWS_body_with_conttributors.md -r https://github.com/dracut-ng/dracut | sed '1,2d' > NEWS_body_full.md

# Use diff to separate new release information and remove repeated empty lines
diff NEWS_body_with_conttributors.md NEWS_body_full.md | grep -e ^\>\  | sed s/^\>\ // | cat -s > NEWS_body_new.md
cat NEWS_header.md NEWS_header_new.md NEWS_body_new.md NEWS_body_with_conttributors.md > NEWS.md

# message for https://github.com/dracut-ng/dracut/releases/tag
cat -s NEWS_body_new.md CONTRIBUTORS.md > release.md

# update DRACUT_VERSION
sed -i "s;^\(DRACUT_VERSION\)=\".*\"$;\1=\"${NEW_VERSION}\";" dracut.sh

if [ -z "$(git config --get user.name)" ]; then
    git config user.name "dracutng[bot]"
fi

if [ -z "$(git config --get user.email)" ]; then
    git config user.email "<dracutng@localhost.localdomain>"
fi

# Check in AUTHORS and NEWS.md
git commit -m "docs: update NEWS.md and AUTHORS for release $NEW_VERSION" NEWS.md AUTHORS dracut.sh

# git push can fail due to insufficient permissions
if ! git push --force -u origin release; then
    exit $?
fi

# tagging and release genaration is no longer automated
# Once the created release commit is merged, create a (signed) release tag:
#
# DRACUT_VERSION=$(sed -n 's/^DRACUT_VERSION="\(.*\)"$/\1/p' dracut.sh)
# git tag -s -m "Dracut $DRACUT_VERSION release" "$DRACUT_VERSION"
