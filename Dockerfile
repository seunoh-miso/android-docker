FROM ubuntu:16.04

MAINTAINER Seun Oh <"seunoh@getmiso.com">

# ================================================================================================================================================================
# Android dependencies
# ================================================================================================================================================================

RUN apt-get update && \
    apt-get install -y unzip && \
    apt-get install -y curl && \
    apt-get install -y openjdk-8-jdk

# Install Kotlin
ENV KOTLIN_VERSION "1.2.10"
ENV KOTLIN_COMPILER_URL https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip
ENV KOTLIN_HOME /opt/kotlin

RUN curl -L "${KOTLIN_COMPILER_URL}" -o /tmp/kotlin.zip && \
    unzip /tmp/kotlin.zip -d ${KOTLIN_HOME} && \
    rm /tmp/kotlin.zip

ENV PATH ${KOTLIN_HOME}/kotlinc/bin:$PATH

# Install Gradle

ENV GRADLE_VERSION "4.1-all"
ENV GRADLE_URL  https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}.zip
ENV GRADLE_HOME /opt/gradle

RUN curl -L "${GRADLE_URL}" -o /tmp/gradle.zip && \
    unzip /tmp/gradle.zip -d ${GRADLE_HOME} && \
    rm /tmp/gradle.zip

ENV PATH ${GRADLE_HOME}/bin:$PATH

# Download and  Android SDK
ENV ANDROID_SDK_VERSION "3859397"
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux

RUN curl -L "${ANDROID_SDK_URL}" -o /tmp/android-sdk.zip && \ 
    unzip /tmp/android-sdk.zip -d ${ANDROID_HOME} && \
    rm /tmp/android-sdk.zip

ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:$PATH

# Fixed Warning messages.
# Warning: File /root/.android/repositories.cfg could not be loaded.
RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg

# Install Android SDK components
ENV ANDROID_PLATFORM_TOOLS_COMPONENTS "platform-tools"
ENV ANDROID_BUILD_TOOLS_COMPONENTS "build-tools;27.0.1"
ENV ANDROID_PLATFORM_COMPONENTS "platforms;android-26 platforms;android-27"
ENV ANDROID_NDK_COMPONENTS "cmake;3.6.4111459 ndk-bundle"
ENV ANDROID_COMPONENTS "${ANDROID_PLATFORM_TOOLS_COMPONENTS} ${ANDROID_BUILD_TOOLS_COMPONENTS} ${ANDROID_PLATFORM_COMPONENTS} ${ANDROID_NDK_COMPONENTS}"

RUN for component in ${ANDROID_COMPONENTS}; do echo y | ${ANDROID_HOME}/tools/bin/sdkmanager "${component}"; done

RUN mkdir /app
WORKDIR /app
ADD . /app
# RUN ./gradlew clean
RUN ./gradlew build
RUN ["chmod", "+x", "/app/script/docker-entrypoint.sh"]
ENTRYPOINT ["/app/script/docker-entrypoint.sh"]