# syntax=docker/dockerfile:1
FROM dart:stable AS builder

# Build binaries
COPY . /source
WORKDIR /source
ENV PUB_CACHE=/source/.pub-cache
RUN mkdir /build \
    && dart pub get \
    && dart compile exe bin/git_lfs_server.dart --output /build/git-lfs-server \
    && dart compile exe bin/git_lfs_authenticate.dart --output /build/git-lfs-authenticate

FROM debian:bullseye-slim
# Install built binaries
COPY --from=builder /build/ /usr/local/bin/

RUN apt-get -qq update && apt-get -qq upgrade -y \
    && apt-get -qq install -y openssh-server git curl bash \
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt-get -qq update && apt-get -qq install -y git-lfs \
    && apt-get -qq clean && apt-get -qq autoclean && rm -rf /tmp/* \
    && echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

ARG USER="git"
ARG UID="1000"
ARG GROUP="git"
ARG GID="1000"

RUN echo `which git-shell` >> /etc/shells
RUN useradd --create-home --shell `which git-shell` --uid ${UID} --user-group ${USER}
USER ${USER}
RUN mkdir -p /home/${USER}/.ssh && \
    chmod 700 /home/${USER}/.ssh && \
    touch /home/${USER}/.ssh/authorized_keys && \
    chmod 644 /home/${USER}/.ssh/authorized_keys
RUN mkdir -p /home/${USER}/git-shell-commands && \
    ln -s /usr/local/bin/git-lfs-authenticate /home/${USER}/git-shell-commands/git-lfs-authenticate && \
    ln -s /usr/local/bin/git-lfs-server /home/${USER}/git-shell-commands/git-lfs-server

USER root
COPY ./startup.sh /
EXPOSE 22 8443

WORKDIR /home/${USER}
RUN echo ${USER} > /home/${USER}/user.txt
CMD ["/bin/sh", "/startup.sh"]
