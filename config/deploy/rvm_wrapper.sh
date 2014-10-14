#!/usr/bin/env bash

# it seems when god drops privileges via Process::Sys.setuid/gid
# we do not inherit the proper environment. therefore we must be very
# careful and use workarounds and/or absolute paths.
#
# i.e., in this case, $rvm_path would would inherit from root and we want
#       to be very explicit about which ruby to use.

if [[ $USE_RVM == "system" ]]; then
  rvm_env="/usr/local/rvm/environments/$USE_RUBY_VERSION"
else
  home=$(echo ~)
  rvm_env="$home/.rvm/environments/$USE_RUBY_VERSION"
fi

if [ ! -f $rvm_env ]; then
  echo "Ruby version '$USE_RUBY_VERSION' not found at $rvm_env"
  exit 1
fi
source $rvm_env

if [ -f /usr/lib/libtcmalloc_minimal.so.0.1.0 ]; then
  export LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.0.1.0
fi

# Ruby GC tuning
# See notes: https://gist.github.com/burke/1688857
#            https://gist.github.com/funny-falcon/4136373

export RUBY_GC_MALLOC_LIMIT=60000000    # 60,000,000
export RUBY_HEAP_FREE_MIN=200000        # 200,000

# other possible vars
# export RUBY_HEAP_MIN_SLOTS=1000000
# export RUBY_HEAP_SLOTS_INCREMENT=1000000
# export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1

$*
