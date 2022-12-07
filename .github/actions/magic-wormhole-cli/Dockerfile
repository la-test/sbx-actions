##############################
# General level requirements #
##############################

# Pull official base image from DockerHub
FROM debian:11

# Avoid warnings while installing the required packages
ARG DEBIAN_FRONTEND=noninteractive

# Prepare locales
ARG LANG=C.UTF-8
ARG LANGUAGE=en_US:en
ARG LC_ALL=C.UTF-8

# Configure desired timezone
ARG TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

##################################
# Application level requirements #
##################################

# Install Python
ARG PYTHON_VERSION=3.9
RUN INSTALL_PKGS="python${PYTHON_VERSION}-minimal python3-pip" && \
    apt-get -q clean && \
    apt-get -q update && \
    apt-get install -y $INSTALL_PKGS && \
    apt-get -q clean

# Upgrade Pip from PyPi
ARG PIP_VERSION='22.3.1'
RUN python${PYTHON_VERSION} -m pip install --upgrade "pip==${PIP_VERSION}"

# Copy requirements
COPY requirements.txt /root/requirements.txt
#RUN chown ${user}:${user} /home/${user}/requirements.txt

# Install requirements
RUN python${PYTHON_VERSION} -m pip install --upgrade -r root/requirements.txt

###########################
# User level requirements #
###########################

# Parameters for default user:group
ARG uid=1000
ARG user=appuser
ARG gid=1000
ARG group=appgroup

# Add or modify user and group for build and runtime (convenient)
RUN id ${user} > /dev/null 2>&1 && \
    { groupmod -g "${gid}" "${group}" && usermod -md /home/${user} -s /bin/bash -g "${group}" -u "${uid}" "${user}"; } || \
    { groupadd -g "${gid}" "${group}" && useradd -md /home/${user} -s /bin/bash -g "${group}" -u "${uid}" "${user}"; }

# Switch to non-root user
USER ${user}
WORKDIR /home/${user}

# Prepare user variables
ENV USER ${user}
ENV HOME=/home/${user}
ENV PATH="${HOME}/.local/bin:${PATH}"
ENV PYTHONPATH="."

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh "${HOME}/.local/bin/entrypoint.sh"

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["entrypoint.sh"]
