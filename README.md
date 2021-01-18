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

## License

[MIT license](./LICENSE)

<br><br><br><br>

# :eight_spoked_asterisk: Changes from [game-ci/docker](https://github.com/game-ci/docker)

* :warning: The `backend-versioning server` is not required
  * The `backend-versioning server` provides Unity versioning and build triggers
  * Instead: [unity-changeset](https://www.npmjs.com/package/unity-changeset) provides Unity versioning based on the official page
  * Instead: `workflow_dispatch` and `schedule` events on GitHub Actions workflow provides build triggers
* Support alpha/beta versions
  * Unity package developers (including me) are concerned about whether their packages will work properly with newer versions of Unity
* Change the image id and tags
  * [mobsakai/unity_editor](https://hub.docker.com/repository/docker/mobsakai/unity_editor)
  * e.g. `mobsakai/unity_editor:2020.1.17f1-base`, `mobsakai/unity_editor:2020.1.17f1-webgl`
* Release automatically with [semantic-release](https://github.com/semantic-release/semantic-release)
  * The version is [based on a committed message](https://www.conventionalcommits.org/)
  * Tagging based on [Semantic Versioning 2.0.0](https://semver.org/)
    * Use `v1.0.0` insted of `v1.0`
* Run workflow automatically
  * Build all images on tag pushed (=released)
  * Build all editor images every day
* Fast skip earlier builds of images that already exist
  * Use `skopeo` to check image tags
* Support environment variables file (`.gitgub/workflow/.env`) for build settings
  * `DOCKER_REGISTRY`: Docker registry. e.g. `docker.io` (Docker Hub), `ghcr.io` (GitHub Container Registory), `gcr.io` (Google Container Registory)
  * `DOCKER_USERNAME`: Username to login docker registry
  * `BASE_IMAGE`
  * `EDITOR_IMAGE`
  * `HUB_IMAGE`
  * `MINIMUM_UNITY_VERSION`
  * `INCLUDE_BETA_VERSIONS`
  * `INCLUDE_IMAGE_TAGS`
  * `EXCLUDE_IMAGE_TAGS`: The build specifies an unstable version and prevents flooding of the error notifications
* Support for alpha/beta versions of Unity (e.g. 2020.2.0b, 2021.1.0a)
  * :warning: **NOTE: The versions removed from [Unity beta](https://unity3d.com/beta) will not be updated**
* Grouping workflows in a module (base, webgl, ...)
  * Improve the visibility of actions page
  * Easy to retry
  * [Fill dynamic matrix](https://github.blog/changelog/2020-04-15-github-actions-new-workflow-features/) to build editor image
* Test project support Unity 2018.3 or later

<br><br>

## :hammer: How to build images

### 1. :pencil2: Setup build configuration file (`.github/workflows/.env`)

[`.github/workflows/.env`](https://github.com/mob-sakai/docker/blob/main/.github/workflows/.env)

<br><br>

### 2. :key: Setup repository secrets

| Name                | Description                                            |
| ------------------- | ------------------------------------------------------ |
| `DOCKERHUB_TOKEN`   | Password or access-token to login docker registory.    |
| `GH_WORKFLOW_TOKEN` | [Github parsonal access token][] to dispatch workflow. |
| `UNITY_LICENSE`     | Contents of an Unity license file (*.ulf)              |

[Github parsonal access token]: https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token

<br><br>

### 3. :arrow_forward: Run workflows automatically

All workflows will be run automatically.

| Workflow              | Description                     | Trigger                            | Inputs                             |
| --------------------- | ------------------------------- | ---------------------------------- | ---------------------------------- |
| `Release`             | Release a new version on GitHub | Pushed to main                     | -                                  |
| `Test`                | Test images                     | Pushed/pull-request                | -                                  |
| `Build All`           | Build all images                | Tag pushed<br>Schedule (Every day) | -                                  |
| `Build Editor Module` | Build an editor image           | Triggered by other workflow        | **module:** Unity module to build. |

<br><br>

## :wrench: Use custom image

### Create manual activation license file (*.alf)

```sh
docker run --rm -v "$(pwd)":/home -w /home -i mobsakai/unity_editor:2020.2.1f1-webgl unity-editor -createManualActivationFile -logFile /dev/stdout
```

### Activate Unity license and generate Unity license file (*.ulf)

```sh
npx unity-activate *.alf --username <UNITY_USERNAME> --password <UNITY_PASSWORD>
```

For details, run `npx unity-acctivate -h`.

### Run the Unity project

```sh
docker run --rm -v "<UNITY_PROJECT_PATH>":/home -w /home -i mobsakai/unity_editor:2020.2.1f1-webgl bash <<EOF
echo '$(cat <ULF_PATH>)' > ulf
unity-editor -logFile /dev/stdout -quit -nographics -manualLicenseFile ulf
unity-editor -logFile /dev/stdout -quit -nographics -projectPath . -executeMethod Method.Full.Path
EOF
```

## :wrench: Use custom image on Github Actions

```yml
- name: Build project
  uses: game-ci/unity-builder@main
  with:
    unityVersion: 2020.1.15f1
    customImage: mobsakai/unity_editor:2020.1.15f1-webgl
    projectPath: .
    targetPlatform: webgl
  env:
    UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}

- name: Test project
  uses: game-ci/unity-test-runner@main
  with:
    unityVersion: 2020.1.15f1
    customImage: mobsakai/unity_editor:2020.1.15f1-webgl
    projectPath: .
    customParameters: -nographics -buildTarget webgl
```

See also:  
https://game.ci/docs/github/getting-started  
https://github.com/webbertakken/unity-test-runner  
https://github.com/webbertakken/unity-builder  

<br><br><br>

## :mag: FAQ

### :exclamation: Error on time limit or API limit

Because the combination of the editor build is so large, the builds may fail due to the time limit of github actions (<6 hours) or API limitations.

Run `Build Editor All` workflow manually after all jobs are done.

### :exclamation: Missing library for editor

If a missing library is found, fix the `editor/Dockerfile`.

<br><br><br>

## :bulb: Next plans

* Notify the error summary to mail, Slack or Discord