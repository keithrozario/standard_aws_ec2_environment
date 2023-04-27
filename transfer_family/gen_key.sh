#! /bin/bash
ssh-keygen -P "" -f transfer-key
ssh-keygen -p -N "" -m pem -f ./transfer-key