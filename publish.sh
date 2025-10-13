#!/bin/bash -e

cd $(dirname $0)

help()
{
    echo "publish editor: ./publish.sh <unityVersion> [module]"
    echo "  unityVersion: e.g. 2020.3.0f1"
    echo "  module: base,linux-il2cpp,windows-mono,mac-mono,ios,android,webgl (default: base)"
}

[ "$1" = "" ] || [ "$1" = "-h" ] && help && exit 0

version=$1
module=${2:-base}
tagVersion=`gh release view --json tagName --jq '.tagName'`

echo "================ PUBLISH =============="
echo "tagVersion: $tagVersion"
echo "version: $version"
changeSet=`npx --yes unity-changeset@latest $1`
echo "changeSet: $changeSet"
echo "module: $module"
echo "image name: unity3d:$version-$module-$tagVersion"
echo "pwd: `pwd`"
echo "======================================="

docker buildx build -f editor/Dockerfile \
  --build-arg version=$version \
  --build-arg changeSet=$changeSet \
  --build-arg module=$module \
  --build-arg hubImage=ghcr.io/mob-sakai/unity3d_hub:$tagVersion \
  --build-arg baseImage=ghcr.io/mob-sakai/unity3d_base:$tagVersion \
  --label "org.opencontainers.image.created=`date -u +'%Y-%m-%dT%H:%M:%SZ'`" \
  --label "org.opencontainers.image.description=`jq -r '.description' package.json`" \
  --label "org.opencontainers.image.documentation=`jq -r '.homepage' package.json`" \
  --label "org.opencontainers.image.licenses=`jq -r '.license' package.json`" \
  --label "org.opencontainers.image.revision=`git rev-parse HEAD`" \
  --label "org.opencontainers.image.source=`jq -r '.homepage' package.json`" \
  --label "org.opencontainers.image.title=docker" \
  --label "org.opencontainers.image.url=`jq -r '.homepage' package.json`" \
  --label "org.opencontainers.image.vendor=`jq -r '.author.name' package.json`" \
  --label "org.opencontainers.image.version=$version-$module-$tagVersion" \
  --tag "ghcr.io/mob-sakai/unity3d:$version-$module-$tagVersion" \
  --tag "ghcr.io/mob-sakai/unity3d:$version-$module" \
  --tag "mobsakai/unity3d:$version-$module-$tagVersion" \
  --tag "mobsakai/unity3d:$version-$module" \
  --push \
  .

echo "Success publish: unity3d:$version-$module-$tagVersion"
