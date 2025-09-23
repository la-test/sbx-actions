#!/usr/bin/env bash

# Configure bash behavior
set -o errexit  # exit on failed command
set -o nounset  # exit on undeclared variables
set -o pipefail # exit on any failed command in pipes

# Verbosity settings
: ${VERBOSE=1}
SH=("/usr/bin/env" "bash")
if [ ${VERBOSE} -ge 2 ]; then
  SH=("${SH[@]}" "-x")
  set -o xtrace
fi

# Set magic variables for current file & dir
__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__FILE="${__DIR}/$(basename "${BASH_SOURCE[0]}")"
__BASE="$(basename ${__FILE} .sh)"
__ROOT="$(cd "$(dirname "${__DIR}")" && pwd)"
__CWD="$(pwd)"

# Explicitely define TMPDIR if required
: ${TMPDIR:='/tmp'}

# Define temp file(s)
TMP_LOG="$(mktemp --tmpdir="${TMPDIR}" "${__BASE}_log.XXXXXXXXXX")"

# Clean exit
on_exit () {
  rm -f "${TMP_LOG}"
  cd "${__CWD}"
}

trap "on_exit" EXIT

# Import all public-keys used by SOPS if the keyring is empty
# This should allow one to mount it own GnuPG home directory
if [ ! -f ~/.gnupg/pubring.kbx ]; then
  while read KEY_NAME KEY_ID; do
    gpg --quiet --import "../secrets/.public-keys/${KEY_NAME}.asc" \
    || echo "WARNING: Could not import ../secrets/.public-keys/${KEY_NAME}.asc"
    gpg --quiet --import-ownertrust <(echo "$(\
      gpg --quiet --with-colons --fingerprint ${KEY_ID} | grep fpr | head -1 | cut -d ':' -f 10\
    ):6:") > /dev/null 2>&1
  done < <(grep -vP '(^\s*#)' ../.sops.yaml | grep -Po '(?<=\&)[^\s]+ [0-9a-fA-F]{40}')
fi

# Call bash with all the arguments
exec "$@"
