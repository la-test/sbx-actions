#!/bin/sh -l

echo -n 'out=' >> $GITHUB_OUTPUT
wormhole "${@}" >> $GITHUB_OUTPUT
