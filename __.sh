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

export BASELINE_VERSION='v. 1.0.0'
export TRUE=1
export FALSE=0

function BASELINE {
	echo "_BASELINE_ $BASELINE_VERSION"
	echo "Type '_help' for additional information"
}
alias _=BASELINE

function BASELINE_TRUE { echo $TRUE; }
alias _TRUE=BASELINE_TRUE

function BASELINE_FALSE { echo $FALSE; }
alias _FALSE=BASELINE_FALSE

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

function BASELINE_str_length { 	tstr="local ssvar=\"$1\"; echo \"\${#ssvar[*]}\""; echo $tstr; }
alias _length=BASELINE_str_length 

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

_isset
_typeof
_length
_ltrim
_rtrim
_trim
_indexof
_substr
_slice
_replace
_split
_arr
_arrlength
_arrindexof
_push
_pop
_shift
_unshift
_concat
_go
_show
_run
_web
_help
'