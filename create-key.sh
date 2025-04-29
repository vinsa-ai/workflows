#!/bin/bash
ssh-keygen -t ed25519 -a 100 -C $1 -f $2
