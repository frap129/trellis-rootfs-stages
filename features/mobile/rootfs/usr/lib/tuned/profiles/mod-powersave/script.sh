#!/bin/bash

. /usr/lib/tuned/functions

start() {
    scxctl switch -m powersave
    disable_bluetooth
    return 0
}

stop() {
    enable_bluetooth
    return 0
}

process $@
