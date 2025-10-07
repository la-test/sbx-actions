##############################
# General level requirements #
##############################

# Pull base image from official repo
FROM node:19.4.0-alpine3.17@sha256:ab3603cb7934b21f1ffb522b1a1d538809516c6e4cd73b144716bc1830aad1a6

# Prepare locales
ARG locale=en_US.UTF-8
ENV LANG "${locale}"
ENV LC_ALL "${locale}"

# Configure desired timezone
ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

##################################
# Application level requirements #
##################################

# Update npm which tend to evolve from the base image
ENV NPM_VERSION 9.3.1
RUN npm install -g npm@$NPM_VERSION

###########################
# User level requirements #
###########################

# Parameters for default user:group
ARG uid=1000
ARG user=node
ARG gid=1000
ARG group=node

# Add user and group for build and runtime
RUN id ${user} > /dev/null 2>&1 || \
    { addgroup -g "${gid}" "${group}" && adduser -D -h /home/${user} -s /bin/bash -G "${group}" -u "${uid}" "${user}"; }

# Copy requirements in non-root user home directory
COPY package.json package-lock.json "/home/${user}/"
RUN chown "${user}:${group}" "/home/${user}/package.json" "/home/${user}/package-lock.json"

# Switch to non-root user
USER ${user}
WORKDIR /home/${user}

# Prepare user variables
ENV USER ${user}
ENV HOME=/home/${user}

# Install required packages
RUN npm clean-install && \
    npm cache clean --force 2> /dev/null

# Adapt paths for NodeJS
ENV NPM_CONFIG_PREFIX=/home/nodejs
ENV NODE_PATH=/home/nodejs/node_modules:/usr/local/lib/node_modules
ENV PATH=/home/nodejs/node_modules/.bin:$PATH
