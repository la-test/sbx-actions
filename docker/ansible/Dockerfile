##############################
# General level requirements #
##############################

# Pull official base image from DockerHub
FROM debian:bookworm-20240812@sha256:aadf411dc9ed5199bc7dab48b3e6ce18f8bbee4f170127f5ff1b75cd8035eb36

# Pass some wellknown variables
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

##################################
# Application level requirements #
##################################

# Install required packages to install Ansible
RUN INSTALL_PKGS="python3-pip python3-venv" && \
    apt-get -q clean && \
    apt-get -q update && \
    apt-get install -y $INSTALL_PKGS && \
    apt-get -q clean

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

# Some extra steps to allow local testing
USER root

# Install some required packages for testing
RUN INSTALL_PKGS="sudo python3-apt openssh-server" && \
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
