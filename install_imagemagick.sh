echo "Installing ImageMagick ..."
install_diamond(){
    DIR=$HOME/$SUNBEAM_ENV_NAME/local
    wget https://www.imagemagick.org/download/ImageMagick.tar.gz -P $DIR
    tar -xzf $DIR/ImageMagick.tar.gz -C $DIR
    rm $DIR/ImageMagick.tar.gz

    cd $DIR/ImageMagick-7.0.6-10
    ./configure --prefix $DIR/ImageMagick
    make
    make install
    command -v $DIR/ImageMagick/bin/convert > /dev/null 2>&1 || \
    { echo "ImageMagick hasn't been properlly install, try installing manually"; exit 1; }
    }
}