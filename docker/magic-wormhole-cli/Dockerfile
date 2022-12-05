##############################
# General level requirements #
##############################

# Pull official base image from DockerHub
FROM debian:11

# Prepare locales
ARG LANG=C.UTF-8
ARG LANGUAGE=en_US:en
ARG LC_ALL=C.UTF-8

# perl: warning: Setting locale failed.
# perl: warning: Please check that your locale settings:
# 	LANGUAGE = "en_US:en",
# 	LC_ALL = "en_US.UTF-8",
# 	LANG = "en_US.UTF-8"
#     are supported and installed on your system.
# perl: warning: Falling back to the standard locale ("C").

# C.UTF-8 ???


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
RUN python${PYTHON_VERSION} -m pip install "pip==${PIP_VERSION}"

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

# Copy requirements
COPY requirements.txt /home/${user}/requirements.txt
#RUN chown ${user}:${user} /home/${user}/requirements.txt

# Install requirements
RUN python${PYTHON_VERSION} -m pip install --user --upgrade -r requirements.txt
