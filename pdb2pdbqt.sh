#! /bin/bash
#
# The skeleton for this script was taken from Stan Watowich's group at the
# University of Texas Medical Branch
# Requires MGL Tools from Scripps: http://mgltools.scripps.edu/

# --- Customizable variables --------------------------------------------------
MGLTOOLS_LOCATION="/scratch/01114/jfonner/mgltools_x86_64Linux2_1.5.4";
# -----------------------------------------------------------------------------

# --- Utility functions -------------------------------------------------------
function die () { echo "$@" 1>&2 ; exit 1; }

function usage () {
  echo "Usage: pdb2pdbqt.sh proteinFile"
  echo "proteinFile should either be a pdb or pdbqt file."
}
# -----------------------------------------------------------------------------


if [ $# -ne 1 ];then
  usage
  exit 0
else
  proteinFile=$1
  
  # If no protein file is present, die.
  if [[ ! -f $proteinFile ]];then
    die "File $proteinFile does not exist."
  fi
  
  # check the file extension
  IS_PDB=false;
  IS_PDBQT=false;
  if [[ ${proteinFile##*.} == pdb ]];then
    IS_PDB=true;
  elif [[ ${proteinFile##*.} == pdbqt ]];then
    IS_PDBQT=true;
  fi

  # # check the contents
  # numChars=`grep -m 1 ^ATOM $proteinFile | wc -m`;
  # numWords=`grep -m 1 ^ATOM $proteinFile | wc -w`;
  # if [[ $numWords -gt 12 ]];then
  #   LOOKS_LIKE_PDBQT=true;
  # else
  #   LOOKS_LIKE_PDBQT=false;
  # fi

  # I'd like to have more rigorous testing in place to distinguish between pdb 
  # and pdbqt, but I'll start with this.
  if [[ $IS_PDBQT != true ]]; then
    echo "Converting Protein from PDB to PDBQT..."
    	
    # The next line removes all HETATMs, which I can only guess is intended to
    # delete a ligand if there happens to be one in the file. Be sure that your
    # protein does not contain atoms errantly marked as a HETATM.
    sed -i '/^HETATM/d' $proteinFile
  
  	PYTHON_INTERPRETER="$MGLTOOLS_LOCATION/bin/pythonsh";
  	LIGAND_SCRIPT="$MGLTOOLS_LOCATION/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py";
  	RECEPTOR_SCRIPT="$MGLTOOLS_LOCATION/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py";
  	PARAMS="-A hydrogens_bonds -U nphs_lps_waters_nonstdres";
  	INFILE="-r $proteinFile";
    pdbqtFile="$(basename $proteinFile .pdb).pdbqt";
  	OUTFILE="-o $pdbqtFile";
  
  	$PYTHON_INTERPRETER $RECEPTOR_SCRIPT $INFILE $OUTFILE $PARAMS > /dev/null

    if [[ ! -f $pdbqtFile ]]; then
    	die "Error: Could not convert .pdb protein file into .pdbqt"
    fi
  fi
fi
