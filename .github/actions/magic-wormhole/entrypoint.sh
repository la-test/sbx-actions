#!/bin/bash

# Prepare temporary files
TMP_OUT="$(mktemp --tmpdir $(basename $0)_out.XXXXXXXXXX)"
TMP_ERR="$(mktemp --tmpdir $(basename $0)_err.XXXXXXXXXX)"

# Make sure they will be deleted
trap "rm -f ${TMP_OUT} ${TMP_ERR}" EXIT

# Call wormhole with all arguments
echo ":rocket: Wormhole data transfer started" >> $GITHUB_STEP_SUMMARY
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
  echo ":scroll: Wormhole data transfer was text based" >> $GITHUB_STEP_SUMMARY
else
  echo ":file_folder: Wormhole data transfer was file based" >> $GITHUB_STEP_SUMMARY
fi

# Change ownership of the output-file for the next step
chown --reference . "${OUTPUT_FILE}"

# Append some info based on the exit code in result and summary
if [ $RET -eq 0 ]; then
  echo "SUCCESS - data has been transfered" >> "${TMP_ERR}"
  echo ":heavy_check_mark: Wormhole data transfer succeeded" >> $GITHUB_STEP_SUMMARY
else
  echo "FAILURE - data has NOT been transfered" >> "${TMP_ERR}"
  echo ":x: Wormhole data transfer failed" >> $GITHUB_STEP_SUMMARY
fi

# Pass stderr as result
echo "result<<$(basename "${TMP_ERR}")" >> $GITHUB_OUTPUT
cat "${TMP_ERR}" >> $GITHUB_OUTPUT
echo "$(basename ${TMP_ERR})" >> $GITHUB_OUTPUT

exit ${RET}
