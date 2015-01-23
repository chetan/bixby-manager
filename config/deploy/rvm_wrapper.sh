#!/usr/bin/env bash

# it seems when god drops privileges via Process::Sys.setuid/gid
# we do not inherit the proper environment. therefore we must be very
# careful and use workarounds and/or absolute paths.
#
# i.e., in this case, $rvm_path would would inherit from root and we want
#       to be very explicit about which ruby to use.

logger $$ "... rvm_wrapper debug start ..."
logger $$ pwd: `pwd`
logger $$ cmd: $*

if [[ $USE_RVM == "system" ]]; then
  # use system-wide install of rvm
  rvm_env="/usr/local/rvm/environments/$USE_RUBY_VERSION"
else
  # use user-local version of rvm
  user=${USE_RVM:-`whoami`}
  rvm_env="/home/$user/.rvm/environments/$USE_RUBY_VERSION"
fi

if [ ! -f $rvm_env ]; then
  echo "Ruby version '$USE_RUBY_VERSION' not found at $rvm_env"
  logger $$ "Ruby version '$USE_RUBY_VERSION' not found at $rvm_env"
  logger $$ "... rvm_wrapper debug end with ERROR ..."
  exit 1
fi

logger $$ "rvm_env: $rvm_env"
logger $$ "... rvm_wrapper debug end ..."

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

if [ ! -z "$RUN_IN_BG" ]; then
  # background and return the pid of the new process (mainly useful when calling puma start)
  $* &
  echo $!
else
  exec $*
fi
