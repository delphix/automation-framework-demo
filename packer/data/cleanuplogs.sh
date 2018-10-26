#!/bin/bash

file="$(find /tmp/archivelog/ -type f -printf "%C@ %f\n" | sort -n | tail -n 1 | awk '{print $NF}')"
pg_archivecleanup /tmp/archivelog/ $file
