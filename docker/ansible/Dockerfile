##############################
# General level requirements #
##############################

# Pull official base image from DockerHub
FROM python:3.9.19-slim-bullseye@sha256:0ebdf1db1fa3673e49d17069ee69157232cbc459b99bb0d68f5c4b0a7487dd0c

# Avoid interactive frontend
ENV DEBIAN_FRONTEND="noninteractive"

##################################
# Application level requirements #
##################################

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

# Upgrade Pip
RUN python -m pip install --disable-pip-version-check --no-cache --upgrade "pip==23.3.2"

# Copy requirements
COPY requirements.txt /home/${user}/requirements.txt

# Install requirements
RUN python -m pip install --user --no-cache --upgrade -r requirements.txt

# Install additional Ansible requirements
COPY requirements.yml /home/${user}/requirements.yml
RUN ansible-galaxy install -r requirements.yml

# Some extra steps to allow local testing
USER root

# Install some required packages for testing
RUN INSTALL_PKGS="sudo python3-apt python3-pip openssh-server" && \
    apt-get -q clean && \
    apt-get -q update && \
    apt-get install -y $INSTALL_PKGS && \
    apt-get -q clean

# Allow user to become while testing playbook locally
RUN echo -n "Defaults:${user} " > /etc/sudoers.d/ansible && \
    echo '!requiretty' >> /etc/sudoers.d/ansible && \
    echo "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ansible

# Switch back to non-root user
USER ${user}
WORKDIR /home/${user}
