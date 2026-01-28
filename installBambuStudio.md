#install bambu studio

git clone https://github.com/bambulab/BambuStudio.git

cd BambuStudio/deps
mkdir build;cd build

sudo apt-get install \
	libgl1-mesa-dev \
	libglu1-mesa-dev\
	nasm \
	yasm \
	libfontconfig1-dev  \
	libwayland-dev \
	libwayland-client0 \
	libwayland-cursor0 \
	libwayland-egl1 \
	wayland-protocols \
	libxkbcommon-dev
	libgtk-3-dev \
	libgtk-3-0 \
	libglib2.0-dev \
	libpango1.0-dev \
	libcairo2-dev \
	libgdk-pixbuf2.0-dev \
	libatk1.0-dev

cmake ../ -DDESTDIR="/home/omokayj/Projects/BambuStudio_dep" -DCMAKE_BUILD_TYPE=Release -DDEP_WX_GTK3=1
make -j4

sudo apt-get install \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-good1.0-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good
    
    
cmake .. -DSLIC3R_STATIC=ON -DSLIC3R_GTK=3 -DBBL_RELEASE_TO_PUBLIC=1 -DCMAKE_PREFIX_PATH="/home/omokayj/Projects/BambuStudio_dep/usr/local" -DCMAKE_INSTALL_PREFIX="../install_dir" -DCMAKE_BUILD_TYPE=Release
cmake --build . --target install --config Release -j3+
