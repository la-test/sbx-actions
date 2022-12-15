#!/bin/sh -l

# Prepare temporary files
TMP_OUT="$(mktemp --tmpdir $(basename $0)_out.XXXXXXXXXX)"
TMP_ERR="$(mktemp --tmpdir $(basename $0)_err.XXXXXXXXXX)"

# Make sure they will be deleted
trap "rm -f ${TMP_OUT} ${TMP_ERR}" EXIT

# Call wormhole with all arguments
wormhole "${@}" > "${TMP_OUT}" 2> "${TMP_ERR}" && RET=0 || RET=1

# Append some info based on the exit code
if [ $RET -eq 0 ]; then
  echo "SUCCESS - data has been transfered" >> "${TMP_ERR}"
else
  echo "FAILURE - data has NOT been transfered" >> "${TMP_ERR}"
fi

# Pass text received from stdout
echo "text<<$(basename "${TMP_OUT}")" >> $GITHUB_OUTPUT
cat "${TMP_OUT}" >> $GITHUB_OUTPUT
echo "$(basename ${TMP_OUT})" >> $GITHUB_OUTPUT

# Pass stderr as result
echo "result<<$(basename "${TMP_ERR}")" >> $GITHUB_OUTPUT
cat "${TMP_ERR}" >> $GITHUB_OUTPUT
echo "$(basename ${TMP_ERR})" >> $GITHUB_OUTPUT

# Pass stderr as step summary too
cat ${TMP_ERR} >> $GITHUB_STEP_SUMMARY

exit ${RET}
