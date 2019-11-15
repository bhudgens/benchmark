#!/usr/bin/env bash

nodemon -e "sh" -x "rsync -rav ./ admiral@cwebster.dev.glgresearch.com:./bhudgens/"
