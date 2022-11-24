#!/usr/bin/env bash

# Configure bash behavior
set -o errexit  # exit on failed command
set -o nounset  # exit on undeclared variables
set -o pipefail # exit on any failed command in pipes

# Set magic variables for current file & dir
__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__FILE="${__DIR}/$(basename "${BASH_SOURCE[0]}")"
__BASE="$(basename ${__FILE} .sh)"
__ROOT="$(cd "$(dirname "${__DIR}")" && pwd)"
__CWD="$(pwd)"

# Explicitely define TMPDIR if required
: ${TMPDIR:='/tmp'}

# Define temp file(s)
SSH_ASKPASS="$(mktemp --tmpdir="${TMPDIR}" ${__BASE}_askpass.XXXXXXXXXX)"
SSH_PRIVKEY="$(mktemp --tmpdir="${TMPDIR}" ${__BASE}_sshkey.XXXXXXXXXX)"
SSH_PUBKEY="${SSH_PRIVKEY}.pub)"

# Clean exit
on_exit () {
  rm -f "${SSH_ASKPASS}" "${SSH_PRIVKEY}" "${SSH_PUBKEY}"
#  ssh-add -d "${SSH_PRIVKEY}"
  cd "${__CWD}"
}

trap "on_exit" EXIT

# Exit if SSH_PASS is not defined
if [ -z "${SSH_PASS-}" ]
then
  echo "${0} could not read SSH_PASS from environment!" > /dev/stderr
  exit 1
fi

# Create simple ssh_askpass
{
  cat <<EOF
#!/usr/bin/env bash
echo "\${SSH_PASS}"
EOF
} > "${SSH_ASKPASS}" \
&& chmod +x "${SSH_ASKPASS}"

# Read encrypted key from input
while read LN; do
  echo "${LN}" >> "${SSH_PRIVKEY}"
done

# Validate the priv key by extracting the pub one
ssh-keygen -e -f "${SSH_PRIVKEY}" -N "${SSH_PASS}" > "${SSH_PUBKEY}" \
|| {
  echo "${0} could not read key from stdin!" > /dev/stderr
  exit 1
}

# Start ssh-agent
if [ -z "${SSH_AGENT_PID-}" ]
then
  eval "$(ssh-agent -s)"
  export SSH_AGENT_PID SSH_AUTH_SOCK
fi

# Add private key to ssh-agent
DISPLAY=":0.0" SSH_ASKPASS="${SSH_ASKPASS}" ssh-add "${SSH_PRIVKEY}" </dev/null > /dev/stderr

# List keys
ssh-add -L
