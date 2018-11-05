# function BASELINE_str_contains(){
# 	STING_NEEDLE=$1
# 	STING_HAYSTACK=$2

# 	if [[ $STING_NEEDLE =~ .*${STING_HAYSTACK}.* ]]; then
# 		echo true
# 	else
# 		echo false
# 	fi
# }

# function BASELINE_str_length(){
# 	STING_NEEDLE=$1
# 	echo ${#1}
# }

# BOURNE AGAIN STANDARDIZED EXECUTION LIBRARY IMPLEMENTATION for NON-ECMASCRIPT

# GLOBAL DECLARATIONS
export BASELINE_VERSION='v. 1.0.0'
export TRUE=1
export FALSE=0

function BASELINE {
	echo "_BASELINE_ $BASELINE_VERSION"
	echo "Type '_help' for additional information"
}
alias _=BASELINE

# GLOBAL METHODS
function BASELINE_TRUE { echo $TRUE; }
alias _TRUE=BASELINE_TRUE

function BASELINE_FALSE { echo $FALSE; }
alias _FALSE=BASELINE_FALSE

#!/usr/bin/env bash

function pad_string() {
	local s_len=${#1};
	echo "$(printf '%-39s' "$1")"
}
function menu_sel {
    ESC=$( printf "\033")
    menu_width=80
    restore_cursor()   { printf "$ESC[?25h"; }

    trap "restore_cursor; stty echo; printf '\n'; exit" 0

    shift_active_row() { printf "$ESC[$1;${2:-1}H"; }
    calc_active_row()  { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    restore_cursor() { printf "$ESC[?25l"; }
    key_input()        { 
  												read -s -n3 key 2>/dev/null >&2
                          if [[ $key = "$ESC[A" ]]; then echo up;    fi;
                          if [[ $key = "$ESC[B" ]]; then echo down;  fi;
                          if [[ $key = ""       ]]; then echo enter; fi;
                        }

    for menu_choice; do printf "\n"; done 																					# Create the menu scaffolding by generating placeholder rows to hold the provided options
					printf '└──────────────────────────────────────────┘'

    local lastrow=`calc_active_row`																									# Ascertain the real current line's position on-screen...
    local startrow=$(($lastrow - $#))																								# ...and count backwards to determine line-feeds needed
    restore_cursor;	  																															# (make sure we give the original line cursor back if Ctrl-C'd)

    local selected=0																																
    while true; do
        local menu_index=0
        for menu_choice; do
            shift_active_row $(($startrow + $menu_index))														# Iterate the skeleton and seed the rows
            [ $menu_index -eq $selected ] && 																				
            printf "│$ESC[7m   $(pad_string $menu_choice)$ESC[27m│" || 
            printf "│   $(pad_string $menu_choice)│"
            ((menu_index++))
        done

        # user key control
        case `key_input` in
            enter) break;;																													# On enter... return the index
            up)    ((selected--));																									# On up... decrement selection (wrapping to last if at 0)
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));																									# On down... opposite of up.
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    shift_active_row $lastrow																												# Move the focus back to the last line (we supplanted)
    printf "\n"																																			# Newline
    restore_cursor																																	# Restore original line cursor

    return $selected
}

function BASELINE_menu {
		local menu_from_arr=$FALSE
		local return_index=$FALSE
		local menu_options=''
		local menu_selection=-1
					echo '┌──────────────────────────────────────────┐'
		while [[ "$menu_selection" == "-1" ]]; do
			case $1 in
				-a|--array)
					menu_from_arr=$TRUE
					shift ;;
				-i|--index)
					return_index=$TRUE
					shift ;;
				-p|--prompt)
					shift 
					echo "│  $(pad_string "$1") │"
					echo '├──────────────────────────────────────────┤'
					shift ;;
				*)
					if [[ $menu_from_arr == $TRUE ]]; then 
						eval "menu_options=(\${$1[*]}) && menu_sel \${$1[*]} 1>&2"
					else
						eval "menu_options=($@)"
						menu_sel "$@" 1>&2
					fi
					menu_selection="$?"
					;;
			esac
		done
    # local result=$?
    [[ $return_index == $FALSE ]] && echo "${menu_options[$menu_selection]}" || echo "$menu_selection"
    return $menu_selection
}
alias _menu=BASELINE_menu


function BASELINE_confirm {
	echo "Y/N"
}

function BASELINE_var_isset  { 
	if [[ -z $1 ]]; then 
		echo $FALSE;
	else
		if [[ ! ${!1} && ${!1-unset} ]]; then
			local tvar="$1"
			echo "FALSE"
		else
			echo $TRUE
		fi
	fi
}
alias _isset=BASELINE_var_isset  

function BASELINE_var_typeof {
	local inp=$1
	local var=$( declare -p $inp 2>&1 | grep "not found")

	[ -f "$inp" ] && echo 'file' && return 0
	[ -d "$inp" ] && echo 'directory' && return 0
	[[ "$var" != "" ]] && echo 'undefined' && return 0

	var=$( declare -p $inp)
	
	local reg='^declare -n [^=]+=\"([^\"]+)\"$'
	while [[ $var =~ $reg ]]; do
		var=$( declare -p ${BASH_REMATCH[inp]} 2> /dev/null | grep -q '^declare \-' )
	done

	case "${var#declare -}" in
		a*)	echo "indexed-array"	;;
		A*)	echo "associative-array"	  ;;
		i*)	echo "int"	  ;;
		x*)	echo "export"	;;
		
		-*)	echo "undeclared"	;;
		 *) echo "string? other?"	;;
	esac
}

alias _typeof=BASELINE_var_typeof  

function BASELINE_length { 	tstr="local ssvar=\"$1\"; echo \"\${#ssvar[*]}\""; echo $tstr; }
alias _length=BASELINE_length 

function BASELINE_str_ltrim  {	echo -e "${1}" | sed -e 's/^[[:space:]]*//' | xargs echo; }
alias _ltrim=BASELINE_str_ltrim  

function BASELINE_str_rtrim  {	echo -e "${1}" | sed -e 's/[[:space:]]*$//' | xargs echo; }
alias _rtrim=BASELINE_str_rtrim  

function BASELINE_str_trim   { echo -e $(str_rtrim "$1" | str_ltrim "$1") | xargs echo;	}
alias _trim=BASELINE_str_trim   

function BASELINE_str_substr { [[ $(var_isset $3) == $TRUE ]] && echo -e ${$1:$2:$3} || echo -e ${$1:$2:$(str_length $1)}; }
alias _substr=BASELINE_str_substr 

function BASELINE_str_replace { echo "$1" | sed "s/$2/$3/"; }
alias _replace=BASELINE_str_replace

function BASELINE_str_split  { 
	echo -e "$(readarray -t -d "\\|" a < <(awk "BEGIN { re=\"$2\" } { gsub(re,\"\\\\\"); print; };" <<<"$1"))?" | xargs echo;
	declare -a a
};
alias _split=BASELINE_str_split







function BASELINE_arr_push(){
		eval "$1=(\"\${$1[@]}\" \"$2\")"
}
alias _push=BASELINE_arr_push

function BASELINE_arr_shift(){
		eval "$1=(\"$2\" \"\${$1[@]}\")"
}
alias _shift=BASELINE_arr_shift






function BASELINE_help {
	case $1 in
		'') 
			echo "_BASELINE_ commands and syntax: 
			$BASELINE_HELPFILE" ;;
		'_TRUE') echo '_BASELINE_ help for _TRUE' ;;
	esac
}
alias _help=BASELINE_help

declare -a _HELPFILE


export BASELINE_HELPFILE='
	$TRUE/$FALSE
		Description:
			Because BASH does not have a constant variable (or even a boolean data type)
			like those in ECMA-Script _TRUE and _FALSE are simply convenient aliases to
			variables equalling 1 and 0, respectively. Note, however, that Bash inverts
			its error codes, with 0 being success and non-0 representing a failure.

		Example Usage:
			[[ $(_isset $some_variable) == $TRUE ]] &&
					echo "some_variable is defined" ||
					echo "some_variable is undefined"

		See also: _TRUE/_FALSE
	
	_TRUE/_FALSE

VARIABLE TYPE-AGNOSTIC METHODS
_isset
_typeof
_length

STRING METHODS
_ltrim
_rtrim
_trim
_indexof
_substr
_slice
_replace
_split

ARRAY METHODS
_arr
_arrindexof
_push
_pop
_shift
_unshift
_concat

SHELL METHODS
_copy
_move
_rename
_find
_fuzzyfind
_go
_b/_back / _f/_forward / _u/_up
_show
_run
_web
_help
'