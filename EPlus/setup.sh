#!/bin/bash

PATH=/glusterfs/users/swiftlang/swift-0.94.1/bin:$PATH

export WORKER_HOSTS=`cat hosts.txt`
start-coaster-service
