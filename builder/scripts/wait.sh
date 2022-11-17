#!/usr/bin/env bash
echo "Waiting for file $FILE"
while [ ! -f "$FILE" ]; do sleep 2; done;