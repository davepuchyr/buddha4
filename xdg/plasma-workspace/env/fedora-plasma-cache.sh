#!/bin/sh

if [ "`kreadconfig5 --file fedora-plasma-cacherc --group 5.46.0 --key FirstRun --default true`" = "true" ]; then
  rm -fv "${XDG_CACHE_HOME:-${HOME}/.cache}"/{*.kcache,plasma-svgelements-*}
  kwriteconfig5 --file fedora-plasma-cacherc --group 5.46.0 --key FirstRun --type bool false
fi
