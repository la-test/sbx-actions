##############################
# General level requirements #
##############################

# Pull base image from official repo
FROM ghcr.io/opentofu/opentofu:1.9.1@sha256:ea67f099effc220a2a2610dd4dd173154408b473bbebe109129f3800eedb19c6

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
