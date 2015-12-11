#!/bin/bash
#
# Author: John Fonner
#
# generate a jobfile containing individual Autodock Vina commands that will be bundled.

# --- Customizable variables --------------------------------------------------
# seconds before killing the task
timeout=600 
# command to run vina
myVina="vina" 
# prefix to the vina command to capture timing info (if desired) 
myTime="/usr/bin/time -o timings.txt --append perl -e 'alarm shift @ARGV; exec @ARGV' $timeout"
# -----------------------------------------------------------------------------

# --- Utility functions -------------------------------------------------------
function die () { echo "$@" 1>&2 ; exit 1; }

function usage () {
  echo "Usage: $0 receptor.pdbqt ligands.txt"
  echo "receptor.pdbqt should be a single target receptor pdbqt file."
  echo "ligands.txt is expected to be the absolute paths of all the ligands to scan."
  echo
  echo "paramgen.sh creates a "jobfile" used by launcher for parallel execution."
  echo "It also creates the directory structure that will be used to hold output."
}
# -----------------------------------------------------------------------------


if [ $# -ne 2 ];then
  usage
  exit 0
else

# Check that it is safe to write output to "jobfile"
  jobfile="jobfile"
  while [ -f $jobfile ]; do
    echo "The file \"${jobfile}\" already exists? Pick a new filename or press Enter to overwrite."
    read input
    if [ "$input" == "" ];then
      rm -f $jobfile
    else
      jobfile=$input
    fi
  done
 
# Error Checking 
  protein=$1
  shift
  if [ ! -f $protein ];then
    die "The protein file $protein does not exist.\n" 
  fi 

  # leave ligands in the $1 slot 
  if [ ! -f $1 ]; then
    die "The file list of ligands $1 does not exist.\n"
  fi

# Make output directories
  if [ ! -d out ];then
    mkdir ./out
  else
    echo "Is it okay to remove and overwrite the output directory?"
    read input
    if [ `echo $input | tr [:upper:] [:lower:]` == "yes" ];then
      rm -rf ./out/*
    else
      die "Error: I need to output into the out directory."
    fi
  fi

# create jobfile
  while read line; do
    # We always divide ligands into subdirectories to protect the filesystem.
    # If you do not, you may want to edit this part of the script.
    subdir=`basename ${line%/*}`
    if [ ! -d ./out/$subdir ];then
      mkdir ./out/$subdir
    fi

    filename=`basename $line`
    echo "$myTime $myVina --config config.in --receptor $protein --ligand $line --out ./out/${subdir}/${filename}  --cpu 1" >> $jobfile
  done < $1
fi

