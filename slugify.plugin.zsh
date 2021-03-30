#: Name        : slugify
#: Date        : 2019-04-08
#: Author      : "lashoun"
#: Version     : 1.2.0
#: Description : Convert filenames into a web friendly format.
#: Options     : See print_usage() function.

function slugify() {
  ## Initialize defaults
  script_name=${0##*/}
  dashes_omit_adjacent_spaces=0
  dots_omit_adjacent_spaces=0
  consolidate_spaces=0
  keep_special_characters=0
  space_replace_char='_'
  ignore_case=0
  interactive=0
  dry_run=0
  nonalnum_to_spaces=0
  nonalnumordash_to_spaces=0
  trim_lead_trail_spaces=1
  dashes_to_spaces=0
  underscores_to_spaces=0
  verbose=0
  clipboard=0

  ## Initialize valid options
  opt_string=abcdefhijnpstuvx

  ## Usage function
  function print_usage(){
    echo "usage: $script_name [-$opt_string] source_file ..."
    echo "   -a: remove spaces immediately adjacent to dashes"
    echo "   -b: remove spaces immediately adjacent to dots"
    echo "   -c: consolidate consecutive spaces into single space"
    echo "   -d: replace spaces with dashes (instead of default underscores)"
    echo "   -e: do not replace special characters with regular characters"
    echo "   -f: treat existing non alpha-numeric characters (except dashes) as spaces"
    echo "   -h: help"
    echo "   -i: ignore case"
    echo "   -j: interactive"
    echo "   -n: dry run"
    echo "   -p: treat existing non alpha-numeric characters as spaces"
    echo "   -s: do not trim leading and trailing spaces"
    echo "   -t: treat existing dashes as spaces"
    echo "   -u: treat existing underscores as spaces (useful with -a, -c, or -d)"
    echo "   -v: verbose"
    echo "   -x: copy to clipboard (WSL)"
  }

  ## Slug function
  function slug() {
    ## Initialize target
    target=$source

    ## Optionally convert special characters to regular characters
    if [ $keep_special_characters -eq 0 ]; then
      target=$(echo "$target" | sed -e "s/[ÊËÉÈ]/E/g" )
      target=$(echo "$target" | sed -e "s/[ÂÄÀÁ]/A/g" )
      target=$(echo "$target" | sed -e "s/[ÔÖÒÓ]/O/g" )
      target=$(echo "$target" | sed -e "s/[ÛÜÙÚ]/U/g" )
      target=$(echo "$target" | sed -e "s/[ÏÎÌÍ]/I/g" )
      target=$(echo "$target" | sed -e "s/Œ/OE/g" )
      target=$(echo "$target" | sed -e "s/[êëéè]/e/g" )
      target=$(echo "$target" | sed -e "s/[âäàá]/a/g" )
      target=$(echo "$target" | sed -e "s/[ôöòó]/o/g" )
      target=$(echo "$target" | sed -e "s/[ûüùú]/u/g" )
      target=$(echo "$target" | sed -e "s/[ïîìí]/i/g" )
      target=$(echo "$target" | sed -e "s/œ/oe/g" )
      target=$(echo "$target" | sed -e "s/Ç/C/g" )
      target=$(echo "$target" | sed -e "s/ç/c/g" )
    fi

    ## Optionally convert to lowercase
    if [ $ignore_case -eq 0 ]; then
      target=$(echo "$target" | tr A-Z a-z )
    fi

    ## Optionally convert existing underscores to spaces
    if [ $underscores_to_spaces -eq 1 ]; then
      target=$(echo "$target" | tr _ ' ')
    fi

    ## Optionally convert existing non alpha-numeric characters to spaces
    if [ $nonalnum_to_spaces -eq 1 ]; then
      target=$(echo "$target" | tr -c '[:alnum:].\n' ' ')
    fi

    ## Optionally convert existing non alpha-numeric characters, except dashes, to spaces
    if [ $nonalnumordash_to_spaces -eq 1 ]; then
      target=$(echo "$target" | tr -c '[:alnum:]-.\n' ' ')
    fi

    ## Optionally convert existing dashes to spaces
    if [ $dashes_to_spaces -eq 1 ]; then
      target=$(echo "$target" | tr - ' ')
    fi

    ## Optionaly consolidate spaces
    if [ $consolidate_spaces -eq 1 ]; then
      target=$(echo "$target" | tr -s ' ')
    fi

    ## Optionally remove spaces immediately adjacent to dashes
    if [ $dashes_omit_adjacent_spaces -eq 1 ]; then
      target=$(echo "$target" | sed 's/\- /-/g')
      target=$(echo "$target" | sed 's/ \-/-/g')
    fi

    ## Optionally remove spaces immediately adjacent to dots
    if [ $dots_omit_adjacent_spaces -eq 1 ]; then
      target=$(echo "$target" | sed 's/\. /./g')
      target=$(echo "$target" | sed 's/ \././g')
    fi

    ## Remove leading and trailing spaces unless explicitly told not to
    if [ $trim_lead_trail_spaces -eq 1 ]; then
      target=$(echo "$target" | xargs echo -n)
    fi

    ## Replace spaces with underscores or dashes
    target=$(echo "$target" | tr ' ' "$space_replace_char")

    ## Handle moving the source to target
    if [ "$target" == "$source" ]; then
      ## If filename hasn't changed, skip move
      ## Print if verbose or dry_run is true
      if [ $verbose -eq 1 -o $dry_run -eq 1 ]; then
        echo "ignore: $source"
      fi
    elif [ -e "$target" -a $case_sensitive_filesystem -eq 1 ]; then
      ## If conflicts with existing filename, skip move and complain
      echo "conflict: $source"
    else
      ## If move is legal
      ## Skip move if dry_run is true
      if [ $dry_run -eq 0 ]; then
        mv "$source" "$target"
      fi
      ## Print if verbose or dry_run is true
      if [ $verbose -eq 1 || $dry_run -eq 1 ]; then
        echo "rename: $source -> $target"
      fi
      ## Copy to clipboard if clipboard is true
      if [ $clipboard -eq 1 ]; then
        echo "$target" | clip.exe
      fi
    fi

  }

  ## For each provided option arg
  while getopts $opt_string opt
  do
    case $opt in
      a) dashes_omit_adjacent_spaces=1 ;;
      b) dots_omit_adjacent_spaces=1 ;;
      c) consolidate_spaces=1 ;;
      d) space_replace_char='-' ;;
      e) keep_special_characters=1 ;;
      f) nonalnumordash_to_spaces=1 ;;
      h) print_usage; return 0 ;;
      i) ignore_case=1 ;;
      j) interactive=1 ;;
      n) dry_run=1 ;;
      p) nonalnum_to_spaces=1 ;;
      s) trim_lead_trail_spaces=0 ;;
      t) dashes_to_spaces=1 ;;
      u) underscores_to_spaces=1 ;;
      v) verbose=1 ;;
      x) clipboard=1 ;;
      *) return 1 ;;
    esac
  done

  ## Remove options from args
  shift "$(( $OPTIND - 1 ))"

  ## Identify case insensitive filesystems
  case_sensitive_filesystem=1
  case $OSTYPE in
    darwin*) case_sensitive_filesystem=0 ;; # OS X
    *) ;; # Do nothing
  esac

    ## Unless source_file arg(s) found, print usage and return (0 to avoid breaking pipes)
    if [[ $interactive -eq 0 && -z "$1" ]]; then
      print_usage
      return 0
    fi


  ## Notify if in dry_run mode
  if [ $dry_run -eq 1 ]; then
    echo "--- Begin dry run mode."
  fi

  if [ $interactive -eq 0 ]; then

    ## For each file, directory, or glob
    for source in "$@"; do

      ## Verify source exists
      if [ ! -e "$source" ]; then
        echo "not found: $source"
        ## Skip to next loop iteration unless in dry run mode
        if [ $dry_run -eq 0 ]; then
          continue
        fi
      fi

      slug

    done
  else
    while true; do
      read source\?'Source: '

      ## Verify source exists
      if [ ! -e "$source" ]; then
        echo "not found: $source"
        ## Skip to next loop iteration unless in dry run mode
        if [ $dry_run -eq 0 ]; then
          continue
        fi
      fi

      slug

    done
  fi

  ## Notify if in dry_run mode
  if [ $dry_run -eq 1 ]; then
    echo "--- End dry run mode."
  fi
}
