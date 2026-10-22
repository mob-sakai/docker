# Development

Clone this repo

```bash
git clone git@github.com:mob-sakai/docker.git
```

Change directory to clone directory

```bash
cd docker
```

Build the editor image

```bash
# build editor: ./build.sh <unityVersion> [module]
#   unityVersion: e.g. 2020.3.0f1
#   module: base,linux-il2cpp,linux-server,windows-mono,windows-coreclr,windows-server,mac-mono,mac-coreclr,mac-server,ios,android,webgl (default: base)
./build.sh 2022.3.16f1 webgl # unity3d:2022.3.16f1-webgl will be created
```

Run the editor image

```bash
# run editor: ./run.sh <command> <unityVersion> [module]
#   command: build,test
#   unityVersion: e.g. 2020.3.0f1
#   module: base,linux-il2cpp,linux-server,windows-mono,windows-coreclr,windows-server,mac-mono,mac-coreclr,mac-server,ios,android,webgl (default: base)
./run.sh build 2022.3.16f1 webgl
./run.sh test 2022.3.16f1 webgl
```
