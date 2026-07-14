##############################
# General level requirements #
##############################

# Pull base image from official repo
FROM ghcr.io/opentofu/opentofu:1.9.4-386@sha256:5d84ad24b28affa53e8970cbc591bacb54ffee1623eb73814422bb59325c2ad8

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
RUN id "${user}" > /dev/null 2>&1 || \
    { addgroup -g "${gid}" "${group}" && adduser -D -h "/home/${user}" -s /bin/bash -G "${group}" -u "${uid}" "${user}"; }

# Switch to user
USER ${user}
