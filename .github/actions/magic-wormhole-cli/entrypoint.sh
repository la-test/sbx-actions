#!/bin/sh -l

echo -n 'out=' >> $GITHUB_OUTPUT
wormhole "${@}" >> $GITHUB_OUTPUT 2> stderr.tmp
echo >> $GITHUB_OUTPUT
echo -n 'err=' >> $GITHUB_OUTPUT
cat stderr.tmp >> $GITHUB_OUTPUT
