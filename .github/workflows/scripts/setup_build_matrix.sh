#!/bin/bash -e

source .github/workflows/.env

MODULE=$1
REF=$2

echo "Module: $MODULE"
echo "Ref: $REF"
echo "Image: $EDITOR_IMAGE:*-$REF"

echo '' > .existtags
skopeo list-tags docker://$EDITOR_IMAGE \
    | jq -r '.Tags[]' \
    | grep -e "-$REF$" > .existtags || :

echo "====================================="
echo "Exist tags"
echo "====================================="
cat .existtags

echo "====================================="
echo "Included image tags"
echo "====================================="
echo -n "$INCLUDE_IMAGE_TAGS" | grep '.' > .includedTags
cat .includedTags

echo "====================================="
echo "Excluded image tags"
echo "====================================="
echo -n "$EXCLUDE_IMAGE_TAGS" | grep '.' > .excludedTags
cat .excludedTags

if [ "$INCLUDE_BETA_VERSIONS" = 'true' ] ; then
    VERSIONS=`npx unity-changeset list --versions --min $MINIMUM_UNITY_VERSION --all || :`
else
    VERSIONS=`npx unity-changeset list --versions --min $MINIMUM_UNITY_VERSION || :`
fi

VERSIONS=`for version in $(echo "$VERSIONS") ; do \
    [ -z "$(grep -x $version-$MODULE-$REF .existtags)" ] \
    && [ -n "$(echo $version-$MODULE-$REF | grep -f .includedTags)" ] \
    && [ -z "$(echo $version-$MODULE-$REF | grep -f .excludedTags)" ] \
    && echo "$version" || : ; \
done`

VERSIONS=`echo "$VERSIONS" | paste -s -d ',' - | sed 's/,/\", \"/g' || :`
[ "$VERSIONS" = '' ] && echo "::warning::No versions to build.%0A[Ignore versions]%0A`cat .ignoreversions`" && echo "::set-output name=skip::true" && exit 0

matrix="{ \
\"version\":[\"$VERSIONS\"], \
\"module\":[\"$MODULE\"] \
}"
echo "$matrix"
echo "::set-output name=matrix::$matrix"
echo "::set-output name=skip::false"