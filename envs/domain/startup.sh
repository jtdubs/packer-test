#!/bin/sh

set -eu

vagrant up dc
vagrnat up web
vagrnat up user
vagrnat up dev
vagrnat up hacker