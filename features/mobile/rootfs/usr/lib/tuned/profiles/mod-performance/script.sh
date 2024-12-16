#!/bin/bash

. /usr/lib/tuned/functions

start() {
    scxctl switch -m lowlatency
    return 0
}

stop() {
    return 0
}

process $@
