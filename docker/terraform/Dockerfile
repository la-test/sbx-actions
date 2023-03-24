##############################
# General level requirements #
##############################

# Pull base image from official repo
ARG terraform_version=latest
FROM hashicorp/terraform:${terraform_version}

# Prepare locales
ARG locale=en_US.UTF-8
ENV LANG "${locale}"
ENV LC_ALL "${locale}"

# Configure desired timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

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
RUN id ${user} > /dev/null 2>&1 || \
    { addgroup -g "${gid}" "${group}" && adduser -D -h /home/${user} -s /bin/bash -G "${group}" -u "${uid}" "${user}"; }

# Switch to user
USER ${user}
