#!/bin/bash -e

cd $(dirname $0)

help()
{
    echo "build editor: ./build.sh <unityVersion> [module]"
    echo "  unityVersion: e.g. 2020.3.0f1"
    echo "  module: base,linux-il2cpp,windows-mono,mac-mono,ios,android,webgl (default: base)"
}

[ "$1" = "" ] || [ "$1" = "-h" ] && help && exit 0

version=$1
module=${2:-base}

echo "================ BUILD ================"
echo "version: $version"
changeSet=`npx --yes unity-changeset@latest $1`
echo "changeSet: $changeSet"
echo "module: $module"
echo "image name: unity3d:$version-$module"
echo "pwd: `pwd`"
echo "======================================="

docker build -t unity3d_base:local -f base/Dockerfile .

docker build -t unity3d_hub:local -f hub/Dockerfile --build-arg baseImage=unity3d_base:local .

docker build -t unity3d:$version-$module -f editor/Dockerfile \
  --build-arg baseImage=unity3d_base:local \
  --build-arg hubImage=unity3d_hub:local \
  --build-arg version=$version \
  --build-arg changeSet=$changeSet \
  --build-arg module=$module \
  .

echo "Success build: unity3d:$version-$module"
