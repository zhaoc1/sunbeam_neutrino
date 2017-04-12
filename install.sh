#!/bin/bash
set -e

PREFIX=$HOME/miniconda3
SUNBEAM_ENV_NAME=${1-sunbeam_neutrino}
echo "For now, the sunbeam environment name need to be sunbeam_neutrino for installing software"

install_conda () {
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $PREFIX
    export PATH=$PATH:$PREFIX/bin
    command -v conda >/dev/null 2>&1 || { echo "Conda still isn't on the path, try installing manually"; exit 1; }
}

command -v conda >/dev/null 2>&1 || { echo "Conda not installed, installing now"; install_conda; }


conda config --add channels r
conda config --add channels bioconda
conda config --add channels eclarke


# Don't create the enviroment if it already exists
conda env list | grep -Fxq $SUNBEAM_ENV_NAME || {
    conda create --name=$SUNBEAM_ENV_NAME --file=requirements.txt --yes;
    source activate $SUNBEAM_ENV_NAME
    pip install  ../sunbeam  #-e create symlink to the sunbeamlib
    pip install git+https://github.com/eclarke/decontam.git
    pip install git+https://github.com/zhaoc1/PathwayAbundanceFinder.git
    echo "$SUNBEAM_ENV_NAME successfully installed.";
}


echo "Now it is time to install some softwares to local/"
echo "Installing metaphlan2 ..."
install_metaphlan2(){
    DIR=$HOME/$SUNBEAM_ENV_NAME/local
    METAPHLAN_VERSION=40d1bf693089
    wget https://bitbucket.org/biobakery/metaphlan2/get/default.zip -P $DIR
    unzip $DIR/default.zip -d $DIR
    # create a empty bowtie2 index prefix file for sunbeamlib path conversion
    touch $DIR/biobakery-metaphlan2-$METAPHLAN_VERSION/db_v20/mpa_v20_m200
    rm $DIR/default.zip
    command -v $DIR/biobakery-metaphlan2-$METAPHLAN_VERSION/metaphlan2.py > /dev/null 2>&1 || \
    { echo "Metaphlan2 hasn't been properlly install, try installing manually"; exit 1; }
    }

if [ ! -f local/default.zip ]; then
    install_metaphlan2;
fi


echo "Installing RAPSearch2 ..."
install_rapsearch2(){
    DIR=$HOME/$SUNBEAM_ENV_NAME/local/RAPSearch2
    git clone https://github.com/zhaoyanswill/RAPSearch2.git $DIR
    cd $DIR
    ./install
    command -v $DIR/bin/rapsearch > /dev/null 2>&1 || \
    { echo "RAPSearch2 hasn't been properlly install, try installing manually"; exit 1; }
    }

if [ ! -d local/RAPSearch2 ]; then
    install_rapsearch2;
fi


echo "Installing CAP3 ..."
install_cap3(){
    DIR=$HOME/$SUNBEAM_ENV_NAME/local
    wget http://seq.cs.iastate.edu/CAP3/cap3.linux.x86_64.tar -P $DIR
    tar -xvf $DIR/cap3.linux.x86_64.tar -C $DIR
    rm $DIR/cap3.linux.x86_64.tar
    command -v $DIR/CAP3/cap3 > /dev/null 2>&1 || \
    { echo "CAP3 hasn't been properlly install, try installing manually"; exit 1; }
    }

if [ ! -d local/CAP3 ]; then
    install_cap3;
fi


echo "To get started, ensure ${PREFIX}/bin is in your path and run 'source activate $SUNBEAM_ENV_NAME'"

