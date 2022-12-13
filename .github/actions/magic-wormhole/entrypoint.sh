#!/bin/sh -l

echo -n 'err=' >> $GITHUB_OUTPUT
wormhole "${@}" 2>> $GITHUB_OUTPUT
