################################################################################
##
## Alces HPC Software Stack - Symphony shell configuration
## Copyright (c) 2008-2012 Alces Software Ltd
##
################################################################################
foreach i ( modules modulerc modulespath )
    if ( ! -f "$HOME/.$i" ) then
	ln -s "$HOME/.alces/etc/$i" "$HOME/.$i"
    endif
end

#if ( -d "$HOME/.alces/core/Modules" ) then
#    alias module alces module
#endif

if ($?tcsh) then
	setenv alces_SHELL "tcsh"
else
	setenv alces_SHELL "csh"
endif
set exec_prefix='$HOME/.alces/core/Modules/bin'

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
    if ( -f "$HOME/.modulespath" ) then
      setenv MODULEPATH `sed -n 's/[      #].*$//; /./H; $ { x; s/^\n//; s/\n/:/g; p; }' $HOME/.modulespath`
    else
      setenv MODULEPATH "$HOME/gridware/etc/modules"
    endif
endif

if (! $?LOADEDMODULES ) then
  setenv LOADEDMODULES ""
endif

alias al 'alces'
# XXX - alces enhanced modules not fully supported under csh :-(
alias mod 'module'
alias alces $prefix'if ( -e $HOME/.alces/bin/alces ) $HOME/.alces/bin/alces \!*; '$postfix
# XXX
# export PS1='$(alces message last)'$PS1

#source modules file from home dir
if ( -r ~/.modules ) then
  source ~/.modules
endif

unset exec_prefix
unset prefix
unset postfix
