##############################
# General level requirements #
##############################

# Pull official base image from DockerHub
FROM debian:12.12-slim@sha256:df52e55e3361a81ac1bead266f3373ee55d29aa50cf0975d440c2be3483d8ed3

# Avoid interactive frontend
ENV DEBIAN_FRONTEND=noninteractive
# Software like Ansible requires the locale encoding to be UTF-8
ENV LANG=C.UTF-8
# Avoid recommended and suggested packages
RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/docker-no-recommends && \
    echo 'APT::Install-Suggests "0";'  > /etc/apt/apt.conf.d/docker-no-suggests

##################################
# Application level requirements #
##################################

# Install required packages to install Ansible
RUN INSTALL_PKGS="curl gnupg nano python3-pip python3-venv ssh" && \
    apt-get -q clean && \
    apt-get -q update && \
    apt-get install -y $INSTALL_PKGS && \
    apt-get -q clean

# Install SOPS runtime
ENV SOPS_VERSION=3.10.2
ENV SOPS_CHECKSUM=79b0f844237bd4b0446e4dc884dbc1765fc7dedc3968f743d5949c6f2e701739
ENV SOPS_BIN=/usr/local/bin/sops
RUN curl --location --no-progress-meter --output "${SOPS_BIN}" \
    https://github.com/getsops/sops/releases/download/v"${SOPS_VERSION}"/sops-"v${SOPS_VERSION}".linux.amd64 \
    && chmod +x "${SOPS_BIN}" \
    && test "$(sha256sum "${SOPS_BIN}" | cut -d' ' -f1)" = "${SOPS_CHECKSUM}"

###########################
# User level requirements #
###########################

# Parameters for default user:group
ARG uid=1000
ARG user=appuser
ARG gid=1000
ARG group=appgroup

# Add user and group for build and runtime
# So the output can be owned by the specified uid:gid
RUN grep -q ":${gid}:" /etc/group && { \
      echo "Group ID ${gid} found"; \
    } || { \
      echo "Group ID ${gid} NOT found"; \
      groupadd -g "${gid}" "${group}" && \
      echo "Group ID ${gid} created"; \
    }
RUN id "${uid}" > /dev/null 2>&1 && { \
      echo "User ID ${uid} found"; \
    } || { \
      echo "User ID ${uid} NOT found"; \
      useradd -md "/home/${user}" -s /bin/bash -g "${group}" -u "${uid}" "${user}" && \
      echo "User ID ${uid} created"; \
    }

# Switch to non-root user
USER ${user}
WORKDIR /home/${user}

# Prepare user variables
ENV USER ${user}
ENV HOME=/home/${user}
ENV PATH="${HOME}/.local/bin:${PATH}"
ENV PYTHONPATH="."

# Prepare the virtual Python env
RUN python3 -m venv --system-site-packages --symlinks .venv
ENV PATH="${HOME}/.venv/bin:${PATH}"

# Copy requirements
COPY requirements.txt /home/${user}/requirements.txt

# Install requirements
# TIP to upgrade/downgrade those:
# - use `python3 -m pip install --no-cache --upgrade ansible[==x.y.z]`,
# - then `python3 -m pip freeze > requirements.txt` to upgrade Ansible and its dependencies.
RUN pip install --no-cache --upgrade -r requirements.txt

# Install additional Ansible requirements
COPY requirements.yml /home/${user}/requirements.yml
RUN ansible-galaxy install -r requirements.yml
RUN umask 077 \
    && mkdir -p ${HOME}/.gnupg \
    && echo "use-agent" >> ${HOME}/.gnupg/gpg.conf

# Prepare entrypoint
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

# Call our entrypoint to automaticaly import all public keys
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
