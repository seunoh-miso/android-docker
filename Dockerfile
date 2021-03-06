FROM ubuntu:16.04

MAINTAINER Seun Oh <"seunoh@getmiso.com">

# ================================================================================================================================================================
# Android dependencies
# ================================================================================================================================================================

RUN apt-get update && \
		apt-get install -y curl unzip openjdk-8-jdk && \
		rm -rf /var/lib/apt/lists/*

# Download and  Android SDK
ARG DEFAULT_ANDROID_SDK_VERSION="3859397"
ENV ANDROID_SDK_VERSION=${DEFAULT_ANDROID_SDK_VERSION}
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK_HOME /opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_HOME}

RUN curl -L "${ANDROID_SDK_URL}" -o /tmp/android-sdk.zip && \
    unzip /tmp/android-sdk.zip -d ${ANDROID_SDK_HOME} && \
    rm /tmp/android-sdk.zip

ENV PATH ${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOME}/platform-tools:$PATH

# Fixed Warning messages.
# Warning: File .android/repositories.cfg could not be loaded.
RUN mkdir -p ${ANDROID_SDK_HOME}/.android && touch ${ANDROID_SDK_HOME}/.android/repositories.cfg

# # Install Android SDK components
ARG DEFAULT_CMAKE_VERSION="3.6.4111459"
ENV CMAKE_VERSION=${DEFAULT_CMAKE_VERSION}
ENV CMAKE_PATH ${ANDROID_SDK_HOME}/cmake/${CMAKE_VERSION}
ENV ANDROID_NDK_HOME ${ANDROID_SDK_HOME}/ndk-bundle
ENV ANDROID_COMPONENTS "cmake;${CMAKE_VERSION} ndk-bundle"

RUN for component in ${ANDROID_COMPONENTS}; do echo y | ${ANDROID_SDK_HOME}/tools/bin/sdkmanager "${component}"; done

ENV PATH ${ANDROID_NDK_HOME}:$PATH

RUN mkdir /app
WORKDIR /app
COPY . /app

RUN find . -name "build" -type d | xargs rm -rf
RUN find . -name ".externalNativeBuild" -type d | xargs rm -rf

RUN echo "\
org.gradle.parallel=true\n \
" > gradle.properties

RUN echo "\
cmake.dir=${CMAKE_PATH}\n \
" > local.properties

ARG KEY_FILE=""
ARG STORE_PASSWORD=""
ARG KEY_ALIAS=""
ARG KEY_PASSWORD=""

ENV RELEASE_KEY_FILE=${KEY_FILE}
ENV RELEASE_STORE_PASSWORD=${STORE_PASSWORD}
ENV RELEASE_KEY_ALIAS=${KEY_ALIAS}
ENV RELEASE_KEY_PASSWORD=${KEY_PASSWORD}

RUN ./gradlew clean

RUN ["chmod", "+x", "/app/script/docker-entrypoint.sh"]
ENTRYPOINT ["/app/script/docker-entrypoint.sh"]