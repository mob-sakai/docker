# Docker Image for Unity3d

CI specialised docker images for Unity3d.

<br><br>

## :wrench: Use the images

The image names and tags are defined as follows:

```sh
# image name/tag
#   - ghcr.io/mob-sakai/unity3d:<UnityVersion>[Module]
#   - docker.io/mobsakai/unity3d:<UnityVersion>[Module]
#   - mobsakai/unity3d:<UnityVersion>[Module]

# Use Unity 2022.3.0f1
$ docker pull ghcr.io/mob-sakai/unity3d:2022.3.0f1

# Use Unity 2022.3.0f1 with the added WebGL module
$ docker pull ghcr.io/mob-sakai/unity3d:2022.3.0f1-webgl
```

- UnityVersion: Required. Specifies the Unity version. Beta versions are also available.
  - `2022.3.5f1`
  - `2023.3.0a6`
- Module: Optional. Specifies the Unity module. (default: `-base`)
  - `-base`: No additional modules. Equivalent to "linux-mono".
  - `-linux-il2cpp`
  - `-linux-server`
  - `-mac-mono`
  - `-windows-mono`
  - `-android`
  - `-ios`
  - `-webgl`

In the following steps, you can activate the Unity license, build the Unity project, and run tests:

```sh
# Mount the current directory to the home directory in the container and start
$ docker run -v "$(pwd):/home" -w "/home" -it ghcr.io/mob-sakai/unity3d:2022.3.0f1-webgl /bin/bash

# In container,
# first, activate the license
/home$ unity-editor -batchmode -manualLicenseFile <your_ulf_file>

# Run tests (com.unity.test-framework)
/home$ unity-editor -batchmode -nographics -projectPath . -buildTarget WebGL -runTests

# Build (com.coffee.simple-build-interface)
/home$ unity-editor -batchmode -nographics -projectPath . -buildTarget WebGL -build

# Build (your script)
/home$ unity-editor -batchmode -nographics -projectPath . -buildTarget WebGL -executeMethod YourClass.BuildMethod
```

<br><br>

## :wrench: Use the images on Github Actions

[Unity - Builder](https://github.com/marketplace/actions/unity-builder) and [Unity - Test runner](https://github.com/marketplace/actions/unity-test-runner) actions support `customImage` parameter:

```yml
- uses: game-ci/unity-test-runner@v2
  with:
    customImage: ghcr.io/mob-sakai/unity3d:2020.3.0f1-webgl
    ...
```

```yml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        unityVersion:
          [
            2019.3.15f1,
            2019.4.16f1,
            2020.1.16f1,
          ]
        include:
          - targetPlatform: StandaloneLinux64
            module: -base
          - targetPlatform: StandaloneOSX
            module: -mac
          - targetPlatform: StandaloneWindows64
            module: -windows
          - targetPlatform: iOS
            module: -ios
          - targetPlatform: Android
            module: -android
          - targetPlatform: WebGL
            module: -webgl
    steps:
      - uses: actions/checkout@v5

      - uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }
        with:
          customImage: ghcr.io/mob-sakai/unity3d:${{ matrix.unityVersion }}${{ matrix.module }}
          customParameters: -nographics
          targetPlatform: ${{ matrix.targetPlatform }}
          githubToken: ${{ github.token }}

      - uses: game-ci/unity-builder@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          customImage: ghcr.io/mob-sakai/unity3d:${{ matrix.unityVersion }}${{ matrix.module }}
          targetPlatform: ${{ matrix.targetPlatform }}

      - uses: actions/upload-artifact@v4
        with:
          name: Build
          path: build
```

For details, see https://game.ci/docs/github/getting-started

<br><br><br><br>
<br><br><br><br>

# :eight_spoked_asterisk: Changes from [game-ci/docker](https://github.com/game-ci/docker)

* Remove original workflows
  * Cats
  * Docs
  * New Versions (Base/Hub/Editor/Retry)
  * PR
* Remove backend-versioning server (Use `workflow_dispatch` and [unity-changeset](https://www.npmjs.com/package/unity-changeset) instead)
* Release automatically with [semantic-release](https://github.com/semantic-release/semantic-release)
  * The release is [based on a committed message](https://www.conventionalcommits.org/)
  * Tagging based on [Semantic Versioning 2.0.0](https://semver.org/)
    * Use `v1.0.0` insted of `v1.0`
* Run build workflow automatically or manually
  * Run workflow when a new version is released in this repository
  * Run workflow when a new version of Unity is released (RSS)
    * https://unity.com/releases/editor/releases.xml
    * https://unity3d.com/unity/beta/latest.xml
    * [Zapier](https://zapier.com/editor/135764435/published/186371035) creates a new comment in [this issue](https://github.com/mob-sakai/docker/issues/28)
    * Run workflow when a comment start with `/build-all`
  * Run workflow daily at 0:00 (UTC)
  * Run workflow manually from [Actions page](../../actions)
* Fast skip earlier builds of images that already exist
* Add build configurations file (`.github/workflow/.env`)
* Support for alpha/beta versions of Unity (e.g. 2022.1.0a, 2021.2.0a)
  * :warning: **NOTE: The versions removed from [Unity beta](https://unity3d.com/beta) will not be updated**
* Grouping workflows in a module (base, ios, android, ...)
  * Improve the visibility of actions page
  * Easy to retry
* Support short image tags (eg. `ghcr.io/mob-sakai/unity3d:2020.3.0f1` for Linux (Mono), `ghcr.io/mob-sakai/unity3d:2020.3.0f1-webgl` for WebGL, etc.)
* Image tags that fail to build twice will automatically be ignored
  * [This locked issue](https://github.com/mob-sakai/docker/issues/19) is used for failure log

<br><br>

## :hammer: How to build images

For details, see https://github.com/mob-sakai/docker/blob/main/DEVELOPMENT.md

### 1. :pencil2: Setup build configurations

#### .minimumUnityVersion

Minimum Unity version for build

```env
2019.4
```


#### .ignoreTags

Excluded image tags for build (Regular expressions)

```env
2019.1
2019.2
2019.3
```

<br><br>

### 2. :key: Setup repository secrets

| Name                | Description                                                    |
| ------------------- | -------------------------------------------------------------- |
| `DOCKER_USERNAME`   | Docker username to login.                                      |
| `DOCKER_PASSWORD`   | Docker password or access token to login.                      |
| `GH_WORKFLOW_TOKEN` | A [Github parsonal access token][] with `workflow` premission. |

[Github parsonal access token]: https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token

<br><br>

### 3. :arrow_forward: Run workflows (automatically)

All workflows will be run automatically.

| Workflow       | Description                                                  | Trigger                                                                         |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| `Release`      | Release new tag.                                             | - Pushed commits (include feat or fix) on `main` branch                         |
| `Build All`    | Build base/hub images and dispatch `Build Editor` workflows. | - Released a new version<br>- Scheduled (daily)<br>- New Unity version released |
| `Build Editor` | Build editor images with a specific Unity module             | - Dispatched from `Build All`                                                   |

<br><br>

### 4. :arrow_forward: Run workflows (manually)

You can run them manually from the [Actions page](../../actions).

**NOTE: You need permissions to run the workflow.**

<br><br><br>

## :mag: FAQ

### :exclamation: Error on time limit or API limit

Because the combination of the editor build is so large, the builds may fail due to the time limit of github actions (<6 hours) or API limitations.

Re-run `Build All` workflow manually after all jobs are done.

### :exclamation: Missing library for editor

If a missing library is found, fix the `editor/Dockerfile` or `base/Dockerfile`.


<br><br><br><br>
<br><br><br><br>

---
:books: << The following is the original Readme >> :books:

# Docker images for Unity

(Not affiliated with Unity Technologies)

Source of CI specialised docker images for Unity, free to use for everyone.

Please find our
[website](https://game.ci)
for any related
[documentation](https://game.ci/docs).

## Base

See the [base readme](./base/README.md) for base image usage.

## Hub

See the [hub readme](./hub/README.md) for hub image usage. 

## Editor

See the [editor readme](./editor/README.md) for editor image usage.

## Community

Feel free to join us on
<a href="http://game.ci/discord"><img height="30" src="media/Discord-Logo.svg" alt="Discord" /></a>
and engage with the community.

## Contributing

To contribute, please see the [development readme](./DEVELOPMENT.md) 
after you agree with our [code of conduct](./CODE_OF_CONDUCT.md) 
and have read the [contribution guide](./CONTRIBUTING.md).

## Support us

GameCI is free for everyone forever.

You can support us at [OpenCollective](https://opencollective.com/game-ci).

## Licence

This repository is [MIT](./LICENSE) licensed.

This includes all contributions from the community.
