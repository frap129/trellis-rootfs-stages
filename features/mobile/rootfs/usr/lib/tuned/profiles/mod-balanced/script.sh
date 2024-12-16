#!/bin/bash

. /usr/lib/tuned/functions

start() {
    scxctl switch -m auto
    return 0
}

stop() {
    return 0
}

process $@
