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

ARG ANDROID_NDK_VERSION=16.1.4479499
ARG ANDROID_BUILD_TOOLS_VERSION=29.0.3
ARG ANDROID_PLATFORM_VERSION=29

# Setup Android SDK/JDK Environment Variables
ENV ANDROID_INSTALL_LOCATION=${UNITY_PATH}/Editor/Data/PlaybackEngines/AndroidPlayer
ENV ANDROID_SDK_ROOT=${ANDROID_INSTALL_LOCATION}/SDK
ENV ANDROID_HOME=${ANDROID_SDK_ROOT}
ENV ANDROID_NDK_HOME=${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK_VERSION}
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}

# install openJDK 8
RUN apt-get update -qq \
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
    && rm -rf /tmp/*