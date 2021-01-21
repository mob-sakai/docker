ARG hubImage="unityci/hub"
ARG baseImage="unityci/base"

###########################
#         Builder         #
###########################

FROM $hubImage AS builder

# Install editor
ARG version
ARG changeSet
RUN unity-hub install --version "$version" --changeset "$changeSet" | grep 'Error' | exit $(wc -l)

# Install modules for that editor
ARG module="non-existent-module"
RUN if [ "$module" = "base" ] ; then \
      echo "running default modules for this baseOs" ; exit 0 ; \
    else \
      unity-hub install-modules --version "$version" --module "$module" --childModules | grep 'Missing module' | exit $(wc -l) ; \
    fi

###########################
#          Editor         #
###########################

FROM $baseImage

# Always put "Editor" and "modules.json" directly in $UNITY_PATH
ARG version
ARG module
COPY --from=builder /opt/unity/editors/$version/ "$UNITY_PATH/"

# Add a file containing the version for this build
RUN echo $version > "$UNITY_PATH/version"

# Alias to "unity-editor" with default params
RUN { \
    echo '#!/bin/bash'; \
    echo 'xvfb-run -ae /dev/stdout "$UNITY_PATH/Editor/Unity" -batchmode "$@"'; \
  } > /usr/bin/unity-editor \
  && chmod +x /usr/bin/unity-editor

###########################
#       Extra steps       #
###########################

#=======================================================================================
# [2018.x-android] Install Android SDK/JDK
#=======================================================================================
RUN [ `echo $version-$module | grep -v '^2018.*-android'` ] && exit 0 || : \
  \
  # Environment Variables
  && export ANDROID_NDK_VERSION=16.1.4479499 \
  && export ANDROID_BUILD_TOOLS_VERSION=29.0.3 \
  && export ANDROID_PLATFORM_VERSION=29 \
  \
  # Environment Variables
  && export ANDROID_INSTALL_LOCATION=${UNITY_PATH}/Editor/Data/PlaybackEngines/AndroidPlayer \
  && export ANDROID_SDK_ROOT=${ANDROID_INSTALL_LOCATION}/SDK \
  && export ANDROID_HOME=${ANDROID_SDK_ROOT} \
  && export ANDROID_NDK_HOME=${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK_VERSION} \
  && export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
  && export PATH=$JAVA_HOME/bin:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH} \
  \
  # install openJDK 8
  && apt-get update -qq \
  && apt-get install -qq -y --no-install-recommends software-properties-common \
  && add-apt-repository ppa:openjdk-r/ppa \
  && apt-get update -qq \
  && apt-get install -qq -y --no-install-recommends unzip openjdk-8-jdk \
  \
  # Download Android SDK commandline tools
  && mkdir -p ${ANDROID_SDK_ROOT} \
  && chown -R 777 ${ANDROID_INSTALL_LOCATION} \
  && wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O /tmp/android-sdk.zip \
  && unzip -q /tmp/android-sdk.zip -d ${ANDROID_SDK_ROOT} \
  \
  # Install platform tools and NDK
  && yes | sdkmanager \
    "platform-tools" \
    "ndk;${ANDROID_NDK_VERSION}" \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_PLATFORM_VERSION}" \
    > /dev/null \
  \
  # Accept licenses
  && yes | sdkmanager --licenses \
  \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  \
  # Update alias 'unity-editor'
  && { \
    echo '#!/bin/bash'; \
    echo "export ANDROID_INSTALL_LOCATION=${ANDROID_INSTALL_LOCATION}"; \
    echo "export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}"; \
    echo "export ANDROID_HOME=${ANDROID_HOME}"; \
    echo "export ANDROID_NDK_HOME=${ANDROID_NDK_HOME}"; \
    echo "export JAVA_HOME=${JAVA_HOME}"; \
    echo "export PATH=${PATH}"; \
    echo 'xvfb-run -ae /dev/stdout "$UNITY_PATH/Editor/Unity" -batchmode "$@"'; \
  } > /usr/bin/unity-editor \
  && chmod +x /usr/bin/unity-editor

#=======================================================================================
# [webgl, il2cpp] python build-essential clang
#=======================================================================================
RUN [ `echo $module | grep -v '\(webgl\|linux-il2cpp\)'` ] && exit 0 || : \
  && apt-get -q update \
  && apt-get -q install -y --no-install-recommends --allow-downgrades \
    python \
    build-essential \
    clang \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#=======================================================================================
# [2019.1.x] libnotify4 libunwind-dev libssl1.0
#=======================================================================================
RUN [ `echo $version | grep -v '^2019.1.'` ] && exit 0 || : \
  && apt-get -q update \
  && apt-get -q install -y --no-install-recommends --allow-downgrades \
    libnotify4 \
    libunwind-dev \
    libssl1.0  \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#=======================================================================================
# [2019.3.x-linux-il2cpp] IL2CPP_ADDITIONAL_ARGS='--sysroot-path=/ --tool-chain-path=/'
#=======================================================================================
RUN [ `echo $version-$module | grep -v '^2019.3.*-linux-il2cpp'` ] && exit 0 || : \
  && { \
    echo '#!/bin/bash'; \
    echo 'export IL2CPP_ADDITIONAL_ARGS="--sysroot-path=/ --tool-chain-path=/"'; \
    echo 'xvfb-run -ae /dev/stdout "$UNITY_PATH/Editor/Unity" -batchmode "$@"'; \
  } > /usr/bin/unity-editor \
  && chmod +x /usr/bin/unity-editor

#=======================================================================================
# [2021.x-linux-il2cpp] lld
#=======================================================================================
RUN [ `echo $version-$module | grep -v '^2021.*-linux-il2cpp'` ] && exit 0 || : \
  && apt-get -q update \
  && apt-get -q install -y --no-install-recommends --allow-downgrades \
    lld \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN echo "test"
