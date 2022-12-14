#!/bin/sh -l

echo -n 'out="' >> $GITHUB_OUTPUT
wormhole "${@}" >> $GITHUB_OUTPUT 2> $GITHUB_STEP_SUMMARY
echo '"' >> $GITHUB_OUTPUT
echo -n 'err="$(tail -1 $GITHUB_STEP_SUMMARY)"' >> $GITHUB_OUTPUT
