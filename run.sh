#!/bin/bash -e

help()
{
    echo "run editor: ./run.sh <command> <unityVersion> [module]"
    echo "  command: build,test,bash"
    echo "  unityVersion: e.g. 2020.3.0f1"
    echo "  module: base,linux-il2cpp,linux-server,windows-mono,windows-coreclr,windows-server,mac-mono,mac-coreclr,mac-server,ios,android,webgl (default: base)"
}

[ "$1" = "" ] || [ "$2" = "" ] || [ "$1" = "-h" ] && help && exit 0

command=$1
version=$2
module=${3:-base}

# Determine build target based on module
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


echo "================ RUN ================"
echo "command: $command"
echo "version: $version"
echo "module: $module"
echo "buildTarget: $buildTarget"
echo "image name: unity3d:$version-$module-local"
echo "pwd: `pwd`"
echo "====================================="


# Build image if not found locally
if [ -z "$(docker image ls -q unity3d:$version-$module-local)" ]; then
  cd $(dirname $0)
  echo "unity3d:$version-$module-local is not found in local."
  ./build.sh $version $module
fi

# Change to reference project directory
cd reference-project

if [ "$(find . -maxdepth 1  -name '*.ulf')" = "" ]; then
  set +e
  docker run -i -w /home -v "$(pwd):/home" --shm-size=1025M unity3d:$version-$module-local /bin/bash <<EOF
unity-editor -nographics -createManualActivationFile
EOF
  set -e

  echo "Unity license file (*.ulf) is not found in 'reference-project' directory."
  npx --yes unity-activate *.alf
fi

if [ "$command" = "build" ]; then
  docker run -i -w /home -v "$(pwd):/home" --shm-size=1025M unity3d:$version-$module-local /bin/bash <<EOF
unity-editor -nographics -manualLicenseFile *.ulf
unity-editor -nographics -accept-apiupdate -projectPath . -buildTarget $buildTarget -build
EOF

elif [ "$command" = "test" ]; then
  docker run -i -w /home -v "$(pwd):/home" --shm-size=1025M unity3d:$version-$module-local /bin/bash <<EOF
unity-editor -nographics -manualLicenseFile *.ulf
unity-editor -nographics -accept-apiupdate -projectPath . -buildTarget $buildTarget -runTests
EOF

elif [ "$command" = "bash" ]; then
  docker run -it -w /home -v "$(pwd):/home" unity3d:$version-$module-local /bin/bash
fi

[ "$?" = "0" ] && echo "==== succeeded ====" || echo "==== failed ===="
