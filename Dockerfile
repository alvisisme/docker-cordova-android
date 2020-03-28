FROM ubuntu:18.04

# Android SDK
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y --no-install-recommends install \
      openjdk-8-jdk \
      git \
      wget \
      unzip \
      tar \
      gnupg \
      lib32stdc++6 \
      lib32z1 \
    && rm -rfv /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ARG GRADLE_VERSION
ENV GRADLE_HOME /gradle-${GRADLE_VERSION}
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip -q gradle-${GRADLE_VERSION}-bin.zip \
    && rm gradle-${GRADLE_VERSION}-bin.zip
ENV PATH ${GRADLE_HOME}/bin:$PATH

ENV ANDROID_HOME /android-sdk-linux
ENV ANDROID_SDK_VERSION 4333796
ARG ANDROID_COMPILE_SDK
ARG ANDROID_BUILD_TOOLS

RUN wget -q -O /tmp/android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    unzip -q -d android-sdk-linux /tmp/android-sdk.zip && \
    rm /tmp/android-sdk.zip

ENV PATH ${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:$PATH

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
RUN yes | sdkmanager --licenses >/dev/null && yes | sdkmanager --update >/dev/null
RUN sdkmanager "tools" "platform-tools" >/dev/null

RUN sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null
RUN sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null

# Node and Yarn
RUN groupadd --gid 1000 node &&\
    useradd --uid 1000 --gid node --shell /bin/bash --create-home node

ENV NODE_VERSION 12.13.0

RUN apt-get -q -y update &&\
    DEBIAN_FRONTEND=noninteractive apt-get -q -y --no-install-recommends install \
      curl \
      wget \
      ca-certificates \
      gnupg \
      dirmngr \
      xz-utils &&\
    rm -rf /var/lib/apt/lists/* &&\
    curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" &&\
    tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 --no-same-owner &&\
    rm "node-v$NODE_VERSION-linux-x64.tar.xz" &&\
    apt-get purge -y --auto-remove xz-utils &&\
    ln -s /usr/local/bin/node /usr/local/bin/nodejs
      
ENV YARN_VERSION 1.19.1

RUN set -ex &&\
    curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" &&\
    mkdir -p /opt &&\
    tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ &&\
    ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn &&\
    ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg &&\
    rm yarn-v$YARN_VERSION.tar.gz

RUN npm install -g cordova@9.0.0
