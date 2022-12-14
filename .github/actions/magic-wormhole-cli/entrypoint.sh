#!/bin/sh -l

echo -n 'out=' >> $GITHUB_OUTPUT
wormhole "${@}" 2> $GITHUB_STEP_SUMMARY | tr -d '\n' >> $GITHUB_OUTPUT
echo >> $GITHUB_OUTPUT
echo -n 'err=' >> $GITHUB_OUTPUT
tail -1 $GITHUB_STEP_SUMMARY | tr -d '\n' >> $GITHUB_OUTPUT
echo >> $GITHUB_OUTPUT
