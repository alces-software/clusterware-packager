################################################################################
##
## Alces HPC Software Stack - Symphony shell configuration
## Copyright (c) 2008-2012 Alces Software Ltd
##
################################################################################
if [ "$UID" != "0" ]; then
    if [ "${alces_MODE}" = "system" -a ! -f "${alces_PATH}/.alces-suite" ]; then
        /opt/alces/bin/alces config install
    fi
    for a in modules modulerc modulespath; do
	if [ ! -f "$HOME/.$a" ]; then
	    ln -s "$HOME/.alces/etc/$a" "$HOME/.$a"
	fi
    done
else
    # we are root, so must be using a system-wide installation
    for a in modules modulerc modulespath; do
	if [ ! -f "$HOME/.$a" ]; then
	    cp /opt/alces/etc/skel/$a "$HOME/.$a"
	fi
    done
fi
if [ -d "${alces_PATH}/opt/Modules" ]; then
    module() { alces module "$@" ; }
    if [ "$ZSH_VERSION" ]; then
	export module
    else
	export -f module
    fi
    if [ "${alces_MODE}" = "system" ]; then
      MODULEPATH=`sed -n 's/[      #].*$//; /./H; $ { x; s/^\n//; s/\n/:/g; p; }' /opt/alces/etc/modulespath`
    fi
    if [ -f "$HOME/.modulespath" ]; then
        USERMODULEPATH=`sed -n 's/[     #].*$//; /./H; $ { x; s/^\n//; s/\n/:/g; p; }' "$HOME/.modulespath"`
    else
	USERMODULEPATH="$HOME/gridware/etc/modules"
    fi
    export MODULEPATH="$(eval echo $USERMODULEPATH:$MODULEPATH)"
fi
alias mod="alces module"

# If we're root and system mode, then update.  If we're a user and user mode, then update.
if [ "$UID" = "0" -a "${alces_MODE}" = "system" -o "${alces_MODE}" = "user" ]; then
    if [ -d "${alces_PATH}/var/lib/packager/repos/base" -a ! -f "${alces_PATH}/var/lib/packager/repos/base/.last-update" ]; then
        alces packager update base
        date +%s > "${alces_PATH}/var/lib/packager/repos/base/.last-update"
    fi
fi

# Source modules from home directory
if [ -f ~/.modules ]; then
    source ~/.modules
fi

if [ "$BASH_VERSION" ]; then
#
# Bash commandline completion (bash 3.0 and above) for Modules 3.2.9
#
    _module_avail() {
        "/opt/alces/core/Modules/bin/modulecmd" bash -t avail 2>&1 | sed '
                /:$/d;
                /:ERROR:/d;
                s#^\(.*\)/\(.\+\)(default)#\1\n\1\/\2#;
                s#/(default)##g;
                s#/*$##g;'
    }

    _module_avail_specific() {
        "/opt/alces/core/Modules/bin/modulecmd" bash -t avail 2>&1 | sed '
                /:$/d;
                /:ERROR:/d;
                s#^\(.*\)/\(.\+\)(default)#\1\/\2#;
                s#/(default)##g;
                s#/*$##g;'
    }

    _module_not_yet_loaded() {
        comm -23  <(_module_avail|sort)  <(tr : '\n' <<<${LOADEDMODULES}|sort)
    }

    _module_long_arg_list() {
        local cur="$1" i

        if [[ ${COMP_WORDS[COMP_CWORD-2]} == sw* ]]
        then
            COMPREPLY=( $(compgen -W "$(_module_not_yet_loaded)" -- "$cur") )
            return
        fi
        for ((i = COMP_CWORD - 1; i > 0; i--))
        do case ${COMP_WORDS[$i]} in
                add|load)
                    COMPREPLY=( $(compgen -W "$(_module_not_yet_loaded)" -- "$cur") )
                    break;;
                rm|remove|unload|switch|swap)
                    COMPREPLY=( $(IFS=: compgen -W "${LOADEDMODULES}" -- "$cur") )
                    break;;
            esac
        done
    }

    _module() {
        local cur="$2" prev="$3" cmds opts

        COMPREPLY=()

        cmds="add apropos avail clear display help\
              initadd initclear initlist initprepend initrm initswitch\
              keyword list load purge refresh rm show swap switch\
              unload unuse update use whatis"

        opts="-c -f -h -i -l -s -t -u -v -H -V\
              --create --force  --help  --human   --icase\
              --long   --silent --terse --userlvl --verbose --version"

        case "$prev" in
            add|load)   COMPREPLY=( $(compgen -W "$(_module_not_yet_loaded)" -- "$cur") );;
            rm|remove|unload|switch|swap)
                COMPREPLY=( $(IFS=: compgen -W "${LOADEDMODULES}" -- "$cur") );;
            unuse)              COMPREPLY=( $(IFS=: compgen -W "${MODULEPATH}" -- "$cur") );;
            use|*-a*)   ;;                      # let readline handle the completion
            -u|--userlvl)       COMPREPLY=( $(compgen -W "novice expert advanced" -- "$cur") );;
            display|help|show|whatis)
                COMPREPLY=( $(compgen -W "$(_module_avail)" -- "$cur") );;
            *) if test $COMP_CWORD -gt 2
then
    _module_long_arg_list "$cur"
else
    case "$cur" in
                # The mappings below are optional abbreviations for convenience
        ls)     COMPREPLY="list";;      # map ls -> list
        r*)     COMPREPLY="rm";;        # also covers 'remove'
        sw*)    COMPREPLY="switch";;

        -*)     COMPREPLY=( $(compgen -W "$opts" -- "$cur") );;
        *)      COMPREPLY=( $(compgen -W "$cmds" -- "$cur") );;
    esac
fi;;
        esac
    }

    _alces_packager_list() {
        "/opt/alces/bin/alces" packager list 2>&1 | sed '
                s#^\(.*\)/\(.\+\)(default)#\1\n\1\/\2#;
                s#/*$##g;'
    }

    _alces_package_list_expired() {
        if (($(date +%s)-$alces_PACKAGE_LIST_MTIME > 60)); then
            return 0
        else
            return 1
        fi
    }

    _alces_packager() {
        local cur="$1" prev="$2" cmds opts
        cmds="clean default help info install list purge update"
        if ((COMP_CWORD > 2)); then
            case "$prev" in
                i*)
                    if [ -z "$alces_PACKAGE_LIST" ] || _alces_package_list_expired; then
                        alces_PACKAGE_LIST=$(_alces_packager_list)
                        alces_PACKAGE_LIST_MTIME=$(date +%s)
                    fi
                    COMPREPLY=( $(compgen -W "$alces_PACKAGE_LIST" -- "$cur") )
                    ;;
                p*|c*|d*)
                    # for purge, clean and default, we provide a module list
                    COMPREPLY=( $(compgen -W "$(_module_avail_specific)" -- "$cur") )
                    ;;
            esac
        else
            case "$prev" in
                *)
                    COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
                    ;;
            esac
        fi
    }

    _alces() {
        local cur="$2" prev="$3" cmds opts

        COMPREPLY=()

        cmds="attach config help hub message module packager session"

        if ((COMP_CWORD == 1)); then
            COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
        else
            case "${COMP_WORDS[1]}" in
                p*)
                    _alces_packager "$cur" "$prev"
                    ;;
                mo*)
                    unset COMP_WORDS[0]
                    COMP_CWORD=$(($COMP_CWORD-1))
                    _module "module" "$cur" "$prev"
                    ;;
                *) 
                    case "$cur" in
                        *)
                            COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
                            ;;
                    esac
                    ;;
            esac
        fi
    }

    complete -o default -F _module module mod
    complete -o default -F _alces alces al
fi
