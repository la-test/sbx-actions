#!/bin/sh -l

set -o xtrace

# Prepare temporary files
TMP_OUT="$(mktemp --tmpdir $(basename $0)_out.XXXXXXXXXX)"
TMP_ERR="$(mktemp --tmpdir $(basename $0)_err.XXXXXXXXXX)"

# Make sure they will be deleted
trap "rm -f ${TMP_OUT} ${TMP_ERR}" EXIT

# Call wormhole with all arguments
wormhole "${@}" > "${TMP_OUT}" 2> "${TMP_ERR}"

# Pass output named out from stdout
echo "out=$(cat "${TMP_OUT}")" >> $GITHUB_OUTPUT

# Pass output named err from last line of stderr
echo "err<<$(basename ${TMP_ERR})" >> $GITHUB_OUTPUT
cat "${TMP_ERR}" >> $GITHUB_OUTPUT
echo "$(basename ${TMP_ERR})" >> $GITHUB_OUTPUT

# Preapre step summary from stderr
cat ${TMP_ERR} >> $GITHUB_STEP_SUMMARY
