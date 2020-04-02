#!/bin/bash
echo `wc -c $1 | head -n1 | cut -d " " -f1`/4|bc
