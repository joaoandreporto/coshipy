#!/bin/bash

# init
conda_env_sel=0
# TODO: find a more direct way to get conda env count, i.e. through conda
conda_env_count=$(conda env list | 
                  grep -v '#' | 
                  awk 'NF {count++} END {print count}')
has_ipython="True"
    
function select_conda_env() {
  while [ "$conda_env_sel" -lt 1 ] || 
        [ "$conda_env_sel" -gt "$conda_env_count" ] ||
        [[ "$conda_env_sel" =~ [^[:digit:]] ]]
  do
    read -rp "Choose number of conda env to use for ipython session: " \
         conda_env_sel
  done
  
  case "$has_ipython" in
    "True")
      conda_env_sel="$(conda env list | 
                       grep -v '#' | 
                       awk -v sel="$conda_env_sel" 'NF && NR==sel{print $1}')"
      ;;
    "False")
      conda_env_sel="$(conda search --envs 'ipython' |
                       grep -v '#\|Searching environments' |
                       awk -F "/" \
                           -v sel="$conda_env_sel" \
                           'NF && NR==1{next} NR==sel+1{print $NF}')"
      ;;
  esac
}

function check_ipython() {
  if [ ! "$(which ipython)" ]; then
    has_ipython="False"
    conda deactivate
    printf "ipython could not be found on conda environment %s.\
            \nSearching for valid options...\n" "$conda_env_sel"
    # TODO: find a more direct way to get conda env count, i.e. through conda
    conda_env_count=$(conda search --envs 'ipython' |
                      grep -v '#\|Searching environments' |
                      awk 'NF && NR==1{next} {count++} END {print count}')
    if [ "$conda_env_count" -gt 0 ]; then
      conda search --envs 'ipython' |
        grep -v '#\|Searching environments' |
        awk -F "/" 'NF && NR==1{next} {print NR-1, $NF}' && echo
      conda_env_sel=0 && select_conda_env
      echo "Selected conda environment: $conda_env_sel"
      activate_conda_env
    else
      printf \
        "ipython was not found to be installed among any conda environments. \
        \nPlease install it first and try again.\n"
    fi
  else 
    # launch vipython
    ipython --TerminalInteractiveShell.editing_mode=vi
  fi
}

function activate_conda_env() {
  source "$(conda info --base)"/etc/profile.d/conda.sh
  conda activate "$conda_env_sel"
}

function main() {
# clear the screen
clear

# enumerate available conda environments
echo "Available conda environments:"
conda env list | grep -v '#' | awk 'NF {print NR, $1}' && echo

# select conda environment
select_conda_env
echo "Selected conda environment: $conda_env_sel"

# activate conda environment
activate_conda_env

# check for ipython presence
check_ipython

# release variables
unset conda_env_count
unset conda_env_sel
unset has_ipython

return 0
}

main
