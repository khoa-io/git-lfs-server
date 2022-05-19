# syntax=docker/dockerfile:1
FROM debian:bullseye-slim

ARG USER="git"
ARG UID="1000"
ARG GROUP="git"
ARG GID="1000"
ARG PUBKEY=""

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y openssh-server git curl bash
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get update && apt-get install -y git-lfs

RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
RUN ssh-keygen -A

COPY build/git-lfs-authenticate /usr/local/bin/git-lfs-authenticate
RUN chmod +x /usr/local/bin/git-lfs-authenticate
COPY build/git-lfs-server /usr/local/bin/git-lfs-server
RUN chmod +x /usr/local/bin/git-lfs-server

# TODO: Custom certs
COPY build/certificates/git-lfs-server.crt /etc/git-lfs/certificates/git-lfs-server.crt
COPY build/certificates/git-lfs-server.key /etc/git-lfs/certificates/git-lfs-server.key
COPY build/certificates/git-lfs-server.pem /etc/git-lfs/certificates/git-lfs-server.pem

RUN echo `which git-shell` >> /etc/shells
RUN useradd --create-home --shell `which git-shell` --uid ${UID} --user-group ${USER}
USER ${USER}
RUN mkdir -p /home/${USER}/.ssh && \
    chmod 700 /home/${USER}/.ssh && \
    echo "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $PUBKEY" > /home/${USER}/.ssh/authorized_keys && \
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
