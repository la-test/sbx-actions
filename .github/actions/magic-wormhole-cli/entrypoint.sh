#!/bin/sh -l

set -o xtrace

# Prepare temporary files
TMP_OUT="$(mktemp --tmpdir $(basename $0)_out.XXXXXXXXXX)"
TMP_ERR="$(mktemp --tmpdir $(basename $0)_err.XXXXXXXXXX)"

# Make sure they will be deleted
trap "rm -f ${TMP_OUT} ${TMP_ERR}" EXIT

# Call wormhole with all arguments
wormhole "${@}" > ${TMP_OUT} 2> ${TMP_ERR}

# Prepare output named out from stdout
echo -n 'out=' >> $GITHUB_OUTPUT
cat ${TMP_OUT} | tr -d '\n' >> $GITHUB_OUTPUT
echo >> $GITHUB_OUTPUT

# Prepare output named err from last line of stderr
echo -n 'err=' >> $GITHUB_OUTPUT
tail -1 ${TMP_ERR} | tr -d '\n' >> $GITHUB_OUTPUT
echo >> $GITHUB_OUTPUT

# Preapre step summary from stderr
cat ${TMP_ERR} >> $GITHUB_STEP_SUMMARY
