#!/usr/bin/env bash

# it seems when god drops privileges via Process::Sys.setuid/gid
# we do not inherit the proper environment. therefore we must be very
# careful and use workarounds and/or absolute paths.
#
# i.e., in this case, $rvm_path would would inherit from root and we want
#       to be very explicit about which ruby to use.

if [[ $USE_RVM == "system" ]]; then
  source /usr/local/rvm/environments/$USE_RUBY_VERSION
else
  source /home/`whoami`/.rvm/environments/$USE_RUBY_VERSION
fi

$*
