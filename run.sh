#!/bin/bash -e

help()
{
    echo "run editor: ./run.sh <command> <unityVersion> [module]"
    echo "  command: build,test"
    echo "  unityVersion: e.g. 2020.3.0f1"
    echo "  module: base,linux-il2cpp,linux-server,windows-mono,windows-coreclr,windows-server,mac-mono,mac-coreclr,mac-server,ios,android,webgl (default: base)"
}

[ "$1" = "" ] || [ "$2" = "" ] || [ "$1" = "-h" ] && help && exit 0

command=$1
version=$2
module=${3:-base}


if [ -z "$(docker image ls -q unity3d:$version-$module)" ]; then
  cd $(dirname $0)
  echo "unity3d:$version-$module is not found in local."
  ./build.sh $version $module
fi

if [ "$module" = "base" ] || [ "$module" = "linux-il2cpp" ] || [ "$module" = "linux-server" ]; then
  buildTarget=StandaloneLinux64
elif [ "$module" = "windows-mono" ] || [ "$module" = "windows-coreclr" ] || [ "$module" = "windows-server" ]; then
  buildTarget=StandaloneWindows
elif [ "$module" = "mac-mono" ] || [ "$module" = "mac-coreclr" ] || [ "$module" = "mac-server" ]; then
  buildTarget=StandaloneOSX
elif [ "$module" = "ios" ]; then
  buildTarget=iOS
elif [ "$module" = "android" ]; then
  buildTarget=Android
elif [ "$module" = "webgl" ]; then
  buildTarget=WebGL
fi

cd reference-project

echo "================ RUN ================"
echo "command: $command"
echo "version: $version"
echo "module: $module"
echo "buildTarget: $buildTarget"
echo "image name: unity3d:$version-$module"
echo "pwd: `pwd`"
echo "====================================="


if [ "$(find . -maxdepth 1  -name '*.ulf')" = "" ]; then
  set +e
  docker run -i -w /home -v "$(pwd):/home" unity3d:$version-$module /bin/bash <<EOF
unity-editor -nographics -createManualActivationFile
EOF
  set -e

  echo "Unity license file (*.ulf) is not found in 'reference-project' directory."
  npx --yes unity-activate *.alf
fi

if [ "$command" = "build" ]; then
  docker run -i -w /home -v "$(pwd):/home" unity3d:$version-$module /bin/bash <<EOF
unity-editor -nographics -manualLicenseFile *.ulf
unity-editor -nographics -accept-apiupdate -projectPath . -buildTarget $buildTarget -build
EOF

elif [ "$command" = "test" ]; then
  docker run -i -w /home -v "$(pwd):/home" unity3d:$version-$module /bin/bash <<EOF
unity-editor -nographics -manualLicenseFile *.ulf
unity-editor -nographics -accept-apiupdate -projectPath . -buildTarget $buildTarget -runTests
EOF

fi

[ "$?" = "0" ] && echo "==== succeeded ====" || "==== failed ===="
