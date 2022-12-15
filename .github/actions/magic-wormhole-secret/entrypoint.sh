#!/bin/bash

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

# Prepare temporary files
TMP_OUT="$(mktemp --tmpdir=/root $(basename $0)_out.XXXXXXXXXX)"
TMP_ERR="$(mktemp --tmpdir=/root $(basename $0)_err.XXXXXXXXXX)"

# Make sure they will be deleted
trap "rm -f ${TMP_OUT} ${TMP_ERR}" EXIT

# Call wormhole with all arguments
echo ":rocket: Wormhole secret transfer started" >> $GITHUB_STEP_SUMMARY
wormhole "${@}" > "${TMP_OUT}" 2> "${TMP_ERR}" && RET=0 || RET=1

# Lookup output-file in arguments
OUTPUT_FILE=''
ARGS=("${@}")
for i in "${!ARGS[@]}"; do
  if [[ "\\${ARGS[$i]}" =~ \\(--output-file|-o) ]]; then
    OUTPUT_FILE="${ARGS[$((i+1))]}"
  fi
done

# TODO: Something is wrong if FILE is still empty

# If output-file does not exist, use stdout to create it
if [ ! -s "${OUTPUT_FILE}" ]; then
  cp -a "${TMP_OUT}" "${OUTPUT_FILE}"
  echo ":scroll: Wormhole secret transfer was text based" >> $GITHUB_STEP_SUMMARY
else
  echo ":file_folder: Wormhole secret transfer was file based" >> $GITHUB_STEP_SUMMARY
fi

# Change ownership of the output-file for the next step
chown --reference "${__CWD}" "${OUTPUT_FILE}"

# Append some info based on the exit code in result and summary
if [ $RET -eq 0 ]; then
  echo "SUCCESS - secret has been transfered" >> "${TMP_ERR}"
  echo ":heavy_check_mark: Wormhole secret transfer succeeded" >> $GITHUB_STEP_SUMMARY
else
  echo "FAILURE - secret has NOT been transfered" >> "${TMP_ERR}"
  echo ":x: Wormhole secret transfer failed" >> $GITHUB_STEP_SUMMARY
fi

# Pass stderr as result
echo "result<<$(basename "${TMP_ERR}")" >> $GITHUB_OUTPUT
cat "${TMP_ERR}" >> $GITHUB_OUTPUT
echo "$(basename ${TMP_ERR})" >> $GITHUB_OUTPUT

exit ${RET}
