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

cmake ../ -DDESTDIR="/home/omokayj/Projects/BambuStudio_dep" -DCMAKE_BUILD_TYPE=Release -DDEP_WX_GTK3=1
make -j4


