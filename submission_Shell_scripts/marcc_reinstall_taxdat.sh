#!/bin/bash
#SBATCH --job-name taxdat_reinstall
#SBATCH --time=00:60:00
#SBATCH --mem=2G
#SBATCH --ntasks=1
#SBATCH --partition=defq
#SBATCH --account=aazman1

# Specify toolchain
export GCC_VERSION=9.3.0
export R_VERSION=4.0.2

# Set filepaths for:
## Local R libraries
export CHOLERA_PIPELINE_DIRECTORY=/data/aazman1/$USER/cholera-mapping-pipeline
export R_LIBRARY_DIRECTORY=$HOME/rlibs/cmp/$R_VERSION/gcc/$GCC_VERSION/
## cmdstan repo
# export CMDSTAN_LOCATION=/data/aazman1/$USER/cmdstan

## clone cmdstan (will not fail if already cloned)
#git clone https://github.com/stan-dev/cmdstan.git $CMDSTAN_LOCATION --recurse-submodules
#cd $CMDSTAN_LOCATION

## Update cmdstan
# git reset --hard $CMDSTAN_LOCATION
# git clean -fxd $CMDSTAN_LOCATION
# git pull


## Set up modules
## (we need to do git things since reset removes git)
module purge

ml gcc/$GCC_VERSION
ml openmpi
ml gdal
ml r/$R_VERSION
ml r-magrittr
ml r-optparse
ml r-yaml
ml r-rprojroot
ml r-purrr
ml r-jsonlite
ml r-dplyr
ml r-tidyverse
ml r-stringi
ml r-rstan


## Install new packages required by the taxdat package and the taxdat package itself
cd $CHOLERA_PIPELINE_DIRECTORY
mkdir -p $R_LIBRARY_DIRECTORY \
 && Rscript -e "options(error=quit, status = 1); 
                if (!require(package = 'ISOcodes', character.only = T, lib='$R_LIBRARY_DIRECTORY')) {
                    install.packages('ISOcodes', lib='$R_LIBRARY_DIRECTORY') }; 
                if (!require(package = 'igraph', character.only = T, lib='$R_LIBRARY_DIRECTORY')) {
                    install.packages('igraph', lib='$R_LIBRARY_DIRECTORY') }; 
                if (!require(package = 'roxygen2', character.only = T, lib='$R_LIBRARY_DIRECTORY')) {
                    install.packages('roxygen2', lib='$R_LIBRARY_DIRECTORY') }
                " \
 && Rscript -e "options(error=quit, status = 1); 
                install.packages('$CHOLERA_PIPELINE_DIRECTORY/packages/taxdat', type='source', repos = NULL, lib='$R_LIBRARY_DIRECTORY')"
 ## We need to install these packages again, since they need newer versions than rockfish has available

echo "DONE"