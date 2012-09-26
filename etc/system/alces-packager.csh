################################################################################
##
## Alces HPC Software Stack - Symphony shell configuration
## Copyright (c) 2008-2012 Alces Software Ltd
##
################################################################################
if ( $uid != "0" ) then
    if ( ! -f "$HOME/.alces/.alces-suite" ) then
	/opt/alces/bin/alces config install
    endif
    foreach a ( modules modulerc modulespath )
	if ( ! -f "$HOME/.$a" ) then
	    ln -s "$HOME/.alces/etc/$a" "$HOME/.$a"
	endif
    end
else
    foreach a ( modules modulerc modulespath )
	if ( ! -f "$HOME/.$a" ) then
	    cp /opt/alces/etc/skel/$a "$HOME/.$a"
	endif
    end
endif

set exec_prefix='/opt/alces/core/Modules/bin'

set prefix=""
set postfix=""

if ( $?histchars ) then
  set histchar = `echo $histchars | cut -c1`
  set _histchars = $histchars

  set prefix  = 'unset histchars;'
  set postfix = 'set histchars = $_histchars;'
else
  set histchar = \!
endif

if ($?prompt) then
  set prefix  = "$prefix"'set _prompt="$prompt";set prompt="";'
  set postfix = "$postfix"'set prompt="$_prompt";unset _prompt;'
endif

if ($?noglob) then
  set prefix  = "$prefix""set noglob;"
  set postfix = "$postfix""unset noglob;"
endif
set postfix = "set _exit="'$status'"; $postfix; test 0 = "'$_exit;'

alias module $prefix'eval `'$exec_prefix'/modulecmd '$alces_SHELL' '$histchar'*`; '$postfix

if (! $?MODULEPATH ) then
    setenv MODULEPATH `sed -n 's/[      #].*$//; /./H; $ { x; s/^\n//; s/\n/:/g; p; }' /opt/alces/etc/modulespath`
    if ( -f "$HOME/.modulespath" ) then
      set usermodulepath = `sed -n 's/[     #].*$//; /./H; $ { x; s/^\n//; s/\n/:/g; p; }' "$HOME/.modulespath"`
      setenv MODULEPATH "$usermodulepath":"$MODULEPATH"
    endif
endif

if (! $?LOADEDMODULES ) then
  setenv LOADEDMODULES ""
endif

alias mod 'module'

#source modules file from home dir
if ( -r ~/.modules ) then
  source ~/.modules
endif

unset exec_prefix
unset prefix
unset postfix
