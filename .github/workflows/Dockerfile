ARG tag
FROM unityci/editor:$tag

ARG tag

# Alias to "unity-editor" with default params
RUN { \
    echo '#!/bin/bash'; \
    echo ''; \
    \
    [ `echo $tag | grep -e '^\(2019.3\|2019.4.0\).*-linux-il2cpp'` ] \
        && echo '# [2019.3.x/2019.4.0-linux-il2cpp] https://forum.unity.com/threads/unity-2019-3-linux-il2cpp-player-can-only-be-built-with-linux-error.822210/#post-5633977' \
        && [ `echo $tag | grep -e '^2019.3.[0-5]f'` ] \
          && echo 'export IL2CPP_ADDITIONAL_ARGS="--tool-chain-path=/"' \
          || echo 'export IL2CPP_ADDITIONAL_ARGS="--sysroot-path=/ --tool-chain-path=/"' \
        && echo ''; \
    \
    [ `echo $tag | grep -e '^\(2020.1\|2020.2.0\|2020.2.1\).*-webgl'` ] \
        && echo '# [2020.x/2020.2.0/2020.2.1-webgl] Support GZip compression: https://github.com/game-ci/docker/issues/75' \
        && echo 'export GZIP=-f' \
        && echo ''; \
    \
    echo 'xvfb-run -ae /dev/stdout "$UNITY_PATH/Editor/Unity" -batchmode "$@"'; \
  } > /usr/bin/unity-editor \