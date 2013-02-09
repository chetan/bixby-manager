#!/usr/bin/env bash

# TODO fix path
#
# it seems when god drops privileges via Process::Sys.setuid/gid
# we do not inherit the proper environment. therefore we must be very
# careful and use workarounds and/or absolute paths
#
# i.e., in this case, $rvm_path would would inherit from root

source /home/`whoami`/.rvm/environments/$USE_RUBY_VERSION
$*
