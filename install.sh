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
    pip install  -e ../sunbeam  #create symlink to the sunbeamlib
    pip install git+https://github.com/eclarke/decontam.git
    pip install git+https://github.com/zhaoc1/PathwayAbundanceFinder.git
    echo "$SUNBEAM_ENV_NAME successfully installed.";
}


echo "Now it is time to install some softwares to local/"

echo "Installing metaphlan2 ..."
install_metaphlan2(){
    DIR=$HOME/$SUNBEAM_ENV_NAME/local
    METAPHLAN_VERSION=40d1bf693089
    # 20171101: temporary fix for broken metaplan2 download link
    #wget https://bitbucket.org/biobakery/metaphlan2/get/default.zip -P $DIR
    unzip $DIR/default.zip -d $DIR
    # create a empty bowtie2 index prefix file for sunbeamlib path conversion
    touch $DIR/biobakery-metaphlan2-$METAPHLAN_VERSION/db_v20/mpa_v20_m200
    #rm $DIR/default.zip
    command -v $DIR/biobakery-metaphlan2-$METAPHLAN_VERSION/metaphlan2.py > /dev/null 2>&1 || \
    { echo "Metaphlan2 hasn't been properlly install, try installing manually"; exit 1; }
}

install_metaphlan2;


echo "Installing CAP3 ..."
install_cap3(){
    DIR=$HOME/$SUNBEAM_ENV_NAME/local
    wget http://seq.cs.iastate.edu/CAP3/cap3.linux.x86_64.tar -P $DIR
    tar -xvf $DIR/cap3.linux.x86_64.tar -C $DIR
    rm $DIR/cap3.linux.x86_64.tar
    command -v $DIR/CAP3/cap3 > /dev/null 2>&1 || \
    { echo "CAP3 hasn't been properlly install, try installing manually"; exit 1; }
    }

install_cap3;

echo "Installing ImageMagick ..."
install_imagemagick(){
    DIR=$HOME/$SUNBEAM_ENV_NAME/local
    wget https://www.imagemagick.org/download/ImageMagick.tar.gz -P $DIR
    tar -xzf $DIR/ImageMagick.tar.gz -C $DIR
    rm $DIR/ImageMagick.tar.gz

    cd $DIR/ImageMagick-7.0.7-9
    ./configure --prefix $DIR/ImageMagick
    make
    make install
    command -v $DIR/ImageMagick/bin/convert > /dev/null 2>&1 || \
    { echo "ImageMagick hasn't been properlly install, try installing manually"; exit 1;}
}

if [ ! -d local/ImageMagick ]; then
    install_imagemagick;
fi

echo "Installing igv ..."
install_igv() {
    DIR=$HOME/$SUNBEAM_ENV_NAME/local
    IGV_VER=2.3.68
    wget http://data.broadinstitute.org/igv/projects/downloads/2.3/IGV_${IGV_VER}.zip -P $DIR
    unzip $DIR/IGV_${IGV_VER}.zip -d $DIR
    ln -s IGV_$IGV_VER $DIR/IGV
    # A symlink will confuse igv.sh so I'm using a wrapper script instead
    echo -e "#!/bin/bash\ncd $DIR/IGV && ./igv.sh \$@" > $DIR/IGV/igv
    chmod +x $DIR/IGV/igv
    export PATH=$DIR/IGV:$PATH
    command -v igv >/dev/null 2>&1 || { echo "IGV still isn't on the path, try installing manually"; exit 1; }
}
install_igv;

echo "To get started, ensure ${PREFIX}/bin is in your path and run 'source activate $SUNBEAM_ENV_NAME'"

