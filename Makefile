# This Makefile is a part of 'Love2D Universal'
# A cross-compiled project setup for Love2D games.
# GitHub: https://github.com/Wolfyxon/love2d-universal
#
# This Makefile is a subject of the public domain and released under the Unlicense License (https://unlicense.org)
# You are free to do anything you want :3
# Made by Wolfyxon

###==-- Data --==###

##-- Game data --##
EXE_NAME    := "Love2DTest"
TITLE 	    := "Love 2D Test"
DESCRIPTION := "Test cross compiled Love2D app"
AUTHOR      := "Epic person"
VERSION     := "1.0"
ICON        := "icon.png"

##-- Directories --##
BUILD_DIR    := "build"
SOURCE_DIR   := "src"
SOURCE_BUILD := "${BUILD_DIR}/src"
SOURCE_ZIP   := "${BUILD_DIR}/src.zip"
3DS_NEST_DIR := ${BUILD_DIR}/3ds_nest

##-- Uncategorized files --##
SCRIPTS  := $(wildcard */*.lua)
LOVE_OUT := ${BUILD_DIR}/${EXE_NAME}.love

##-- Love executables to embed the game into --##
# Use `make deps` to install all binaries (except linux)
LOVE_BINARIES       := ${HOME}/.local/lib/build/love

LOVE_LINUX_APPIMAGE_IN  := ${LOVE_BINARIES}/linux.AppImage
LOVE_LINUX_BUILD        := ${BUILD_DIR}/linux
LOVE_LINUX_APPIMAGE_OUT := ${LOVE_LINUX_BUILD}/${EXE_NAME}.AppImage
LOVE_LINUX_FS           := ${LOVE_LINUX_BUILD}/squashfs-root
LOVE_LINUX_FS_BIN       := ${LOVE_LINUX_FS}/bin/love

LOVE_WIN64_SRC      := ${LOVE_BINARIES}/win64
LOVE_WIN64_IN       := ${LOVE_WIN64_SRC}/love.exe
LOVE_WIN64_ZIP      := ${LOVE_BINARIES}/win64.zip
LOVE_WIN64_BUILD    := ${BUILD_DIR}/win64
LOVE_WIN64_OUT      := ${LOVE_WIN64_BUILD}/${EXE_NAME}.exe

LOVE_WIN32_SRC      := ${LOVE_BINARIES}/win32
LOVE_WIN32_IN       := ${LOVE_WIN32_SRC}/love.exe
LOVE_WIN32_ZIP      := ${LOVE_BINARIES}/win32.zip
LOVE_WIN32_BUILD    := ${BUILD_DIR}/win32
LOVE_WIN32_OUT      := ${LOVE_WIN32_BUILD}/${EXE_NAME}.exe

LOVE_3DS_DIR        := ${LOVE_BINARIES}/3ds
LOVE_3DS            := ${LOVE_3DS_DIR}/lovepotion_3ds.elf
LOVE_3DS_ZIP        := ${LOVE_3DS_DIR}/lovepotion_3ds.zip

LOVE_3DS_ASSETS_ZIP := ${LOVE_3DS_DIR}/assets.zip
LOVE_3DS_ROMFS      := ${LOVE_3DS_DIR}/files.romfs

##-- Software --##
LOVE          := love
APPIMAGETOOL  := appimagetool
#- Nintendo 3DS -#
3DS_EMULATOR  := citra
DKP_TOOLS     := /opt/devkitpro/tools/bin
SMDHTOOL      := ${DKP_TOOLS}/smdhtool
3DSXTOOL      := ${DKP_TOOLS}/3dsxtool
3DSLINK       := ${DKP_TOOLS}/3dslink

##- Dependency links and output files -##
LOVE2D_LATEST_RELEASE                  := https://api.github.com/repos/love2d/love/releases/latest
LOVE2D_LATEST_RELEASE_OUTPUT           := /tmp/love2d_latest_release

LOVEPOTION_LATEST_RELEASE              := https://api.github.com/repos/lovebrew/lovepotion/releases/latest
LOVEPOTION_LATEST_RELEASE_OUTPUT       := /tmp/lovepotion_latest_release

LOVEPOTION_ASSETS_LATEST_RELEASE        := https://api.github.com/repos/lovebrew/bundler/releases/latest
LOVEPOTION_ASSETS_LATEST_RELEASE_OUTPUT := /tmp/lovepotion_latest_release_assets

LOVEPOTION_NEST_URL                     := https://github.com/lovebrew/nest/archive/master.tar.gz
LOVEPOTION_NEST                         := ${LOVE_BINARIES}/nest.tar.gz

###==-- Targets --==###

##-- Build & testing targets --##

# Builds for all desktop platforms
pc: linux win64 win32

#- Universal PC -#

${LOVE_OUT}: parse ${BUILD_DIR}
	@echo "> Removing old .love file to prevent adding files"
	rm -f ${LOVE_OUT}

	@echo "> Creating .love file"
	cd ${SOURCE_DIR} && zip -9 -r ../${LOVE_OUT} *

.PHONY: love
love: ${LOVE_OUT}

.PHONY: parse
parse:
	@echo "> Verifying Lua syntax"
	luac -p ${SCRIPTS}


.PHONY: run
run: parse
	@echo "> Running the source directory with LOVE"
	${LOVE} ${SOURCE_DIR} $@

#- Linux -#

# Compile a Linux x86_64 AppImage
.PHONY: linux
linux: ${LOVE_LINUX_APPIMAGE_IN} ${LOVE_OUT}
	@echo "> Creating directory"
	mkdir -p ${LOVE_LINUX_BUILD}

	@echo "> Copying LOVE AppImage into build"
	cp ${LOVE_LINUX_APPIMAGE_IN} ${LOVE_LINUX_APPIMAGE_OUT}
	
	@echo "> Extracting AppImage contents"
	cd ${LOVE_LINUX_BUILD} && "./${EXE_NAME}.AppImage" --appimage-extract

	@echo "> Embedding game code into the executable"
	cat ${LOVE_LINUX_FS_BIN} ${LOVE_OUT} > ${LOVE_LINUX_FS_BIN}.new
	mv ${LOVE_LINUX_FS_BIN}.new ${LOVE_LINUX_FS_BIN}
	chmod +x ${LOVE_LINUX_FS_BIN}

	@echo "> Packaging AppImage"
	${APPIMAGETOOL} ${LOVE_LINUX_FS} "${BUILD_DIR}/${EXE_NAME}.AppImage" 

	@echo "> Portable Linux AppImage available at ${LOVE_LINUX_APPIMAGE_OUT}"

#- Windows -#

# Compile a Windows x86_64 EXE
.PHONY: win64
win64: ${LOVE_WIN64_SRC} ${LOVE_OUT}
	@echo "> Copying love source into build"
	mkdir -p ${LOVE_WIN64_BUILD}
	cp -r ${LOVE_WIN64_SRC}/* ${LOVE_WIN64_BUILD}

	@echo "> Embedding game into the executable"
	cat ${LOVE_WIN64_IN} ${LOVE_OUT} > ${LOVE_WIN64_OUT}
	rm ${LOVE_WIN64_BUILD}/love.exe
	rm ${LOVE_WIN64_BUILD}/lovec.exe

# Compile a Windows x86_32 EXE
.PHONY: win32
win32: ${LOVE_WIN32_SRC} ${LOVE_OUT}
	@echo "> Copying love source into build"
	mkdir -p ${LOVE_WIN32_BUILD}
	cp -r ${LOVE_WIN32_SRC}/* ${LOVE_WIN32_BUILD}

	@echo "> Embedding game into the executable"
	cat ${LOVE_WIN32_IN} ${LOVE_OUT} > ${LOVE_WIN32_OUT}
	rm ${LOVE_WIN32_BUILD}/love.exe
	rm ${LOVE_WIN32_BUILD}/lovec.exe


#- Nintendo 3DS -#

# Compile 3DSX file
.PHONY: 3dsx
3dsx: ${BUILD_DIR}/${EXE_NAME}.3dsx

# Run 3DSX with an emulator
.PHONY: 3ds_emu
3ds_emu: 3dsx
	@echo "> NOTE: LOVEPotion currently does not work on emulators, you most likely will encounter a black screen."
	@echo "  Consider using real hardware or using the old ELF file, although many features might break"
	@echo "> Running the 3DSX file with an emulator"
	${3DS_EMULATOR} ${BUILD_DIR}/${EXE_NAME}.3dsx

# Simulate the 3DS environment with NEST
3ds_nest: ${LOVEPOTION_NEST} ${3DS_NEST_DIR}/nest
	@echo "> Adding NEST to the main script"
	sed -i '1i require("nest").init({console = "3ds"})' ${3DS_NEST_DIR}/main.lua

	@echo "> Running with LOVE"
	${LOVE} ${3DS_NEST_DIR}

# Extract NEST
${3DS_NEST_DIR}/nest: ${3DS_NEST_DIR}
	@echo "> Extracting NEST"
	mkdir -p ${3DS_NEST_DIR}/nest
	cd ${3DS_NEST_DIR}/nest && tar --strip-components=2 -xvzf ${LOVEPOTION_NEST} nest-master/nest

# Copy source to build subdirectory for the 3DS
${3DS_NEST_DIR}: ${BUILD_DIR}
	@echo "> Copying source to ${3DS_NEST_DIR}"
	cp -R ${SOURCE_DIR} ${3DS_NEST_DIR}

# Remotely run 3DSX on a 3DS
.PHONY: 3dslink
3dslink: ${BUILD_DIR}/${EXE_NAME}.3dsx
	${3DSLINK} "${BUILD_DIR}/${EXE_NAME}.3dsx"

${BUILD_DIR}:
	@echo "> Creating build directory"
	-mkdir -p ${BUILD_DIR}

# Compile 3DSX
${BUILD_DIR}/${EXE_NAME}.3dsx: ${BUILD_DIR}/${EXE_NAME}.smdh ${SOURCE_ZIP} ${LOVE_3DS_ROMFS}
#   TODO: Find LOVEPotion RomFS
	@echo "> Compiling 3DSX file"
	${3DSXTOOL} ${LOVE_3DS} ${BUILD_DIR}/${EXE_NAME}.3dsx.tmp --smdh=${BUILD_DIR}/${EXE_NAME}.smdh --romfs=${LOVE_3DS_ROMFS}

	@echo "> Embedding game's code"
	cat ${BUILD_DIR}/${EXE_NAME}.3dsx.tmp ${SOURCE_ZIP} > ${BUILD_DIR}/${EXE_NAME}.3dsx
 
# Compile SMDH
${BUILD_DIR}/${EXE_NAME}.smdh: ${BUILD_DIR}
	@echo "> Compiling SMDH file"
	${SMDHTOOL} --create ${TITLE} ${DESCRIPTION} ${AUTHOR} ${ICON} ${BUILD_DIR}/${EXE_NAME}.smdh

# Prepare game source
${SOURCE_BUILD}:
	@echo "> Copying game code"
	cp -r ${SOURCE_DIR} ${SOURCE_BUILD}

# Convert all images to .t3x
t3x: ${SOURCE_BUILD}
	@echo "> Converting all images to t3x"

	@for file in $(shell find $(SOURCE_BUILD) -type f \( -name "*.png" -o -name "*.jpeg" -o -name "*.jpg" \)); do \
		echo "> Converting $$file"; \
		tex3ds "$$file" -o "$${file%.*}.t3x" -f rgba ; \
	done

${SOURCE_ZIP}: t3x
	@echo "> Archiving game's code"
	cd ${SOURCE_BUILD} && zip -9 -r ../src.zip *

##-- Dependency targets --##

# Shows dependencies info
.PHONY: deps
deps:
	@echo "> Build dependencies are stored in:"
	@echo "> ${LOVE_BINARIES}"
	@echo " "
	@echo "> Dependencies are downloaded automatically when compiling a target for the first time"
	@echo "> Use \`make install_deps\` to download them all"
	@echo "> Use \`make remove_deps\` to remove all installed dependencies"

# Install dependencies for all targets
.PHONY: install_deps
install_deps: ${LOVE_LINUX_APPIMAGE_IN} ${LOVE_WIN64_SRC} ${LOVE_WIN32_SRC} ${LOVE_3DS}

# Removes all LOVE binaries
.PHONY: remove_deps
remove_deps:
	@echo "> Removing all dependencies"
	rm -rf ${LOVE_BINARIES}

# Prepare directory
${LOVE_BINARIES}:
	@echo "> Creating directory"
	mkdir -p ${LOVE_BINARIES}

# Fetch love2D builds
${LOVE2D_LATEST_RELEASE_OUTPUT}: ${LOVE_BINARIES}
	@if [ ! -f ${LOVE2D_LATEST_RELEASE_OUTPUT} ]; then \
		echo "> Fetching love2d builds"; \
		curl -s ${LOVE2D_LATEST_RELEASE} | grep browser_download_url | sed -n 's/.*"browser_download_url": "\(.*\)"/\1/p' > ${LOVE2D_LATEST_RELEASE_OUTPUT}; \
		cat ${LOVE2D_LATEST_RELEASE_OUTPUT}; \
	else \
		echo "> Builds already fetched"; \
	fi

# Fetch LOVEPotion build URLS
${LOVEPOTION_LATEST_RELEASE_OUTPUT}: ${LOVE_BINARIES}
	@if [ ! -f ${LOVEPOTION_LATEST_RELEASE_OUTPUT} ]; then \
		echo "> Fetching LOVEPotion builds"; \
		curl -s ${LOVEPOTION_LATEST_RELEASE} | grep browser_download_url | sed -n 's/.*"browser_download_url": "\(.*\)"/\1/p' > ${LOVEPOTION_LATEST_RELEASE_OUTPUT}; \
		cat ${LOVE2D_LATEST_RELEASE_OUTPUT}; \
	else \
		echo "> LOVEPotion builds already fetched"; \
	fi

# Fetch LOVEPotion assets build URLS
${LOVEPOTION_ASSETS_LATEST_RELEASE_OUTPUT}: ${LOVE_BINARIES}
	@if [ ! -f ${LOVEPOTION_ASSETS_LATEST_RELEASE_OUTPUT} ]; then \
		echo "> Fetching LOVEPotion bundler assets"; \
		curl -s ${LOVEPOTION_ASSETS_LATEST_RELEASE} | grep browser_download_url | sed -n 's/.*"browser_download_url": "\(.*\)"/\1/p' > ${LOVEPOTION_ASSETS_LATEST_RELEASE_OUTPUT}; \
		cat ${LOVEPOTION_ASSETS_LATEST_RELEASE_OUTPUT}; \
	else \
		echo "> LOVEPotion bundler assets already fetched"; \
	fi

#-- Linux --#

# Download Linux AppImage
${LOVE_LINUX_APPIMAGE_IN}: ${LOVE2D_LATEST_RELEASE_OUTPUT}
	@if [ ! -f ${LOVE_LINUX_APPIMAGE_IN} ]; then \
		echo "> Downloading Linux AppImage"; \
		curl -L ${shell cat ${LOVE2D_LATEST_RELEASE_OUTPUT} | grep AppImage } > ${LOVE_LINUX_APPIMAGE_IN}; \
		chmod +x ${LOVE_LINUX_APPIMAGE_IN}; \
	else \
		echo "> Linux AppImage already exists"; \
	fi

# Install Linux dependencies
.PHONY: linux_dep
linux_dep: ${LOVE_LINUX_APPIMAGE_IN}

#-- Win64 --#

# Download win64 archive
${LOVE_WIN64_ZIP}: ${LOVE2D_LATEST_RELEASE_OUTPUT}
	@if [ ! -f ${LOVE_WIN64_ZIP} ]; then \
		echo "> Downloading win64 archive"; \
		curl -L ${shell cat ${LOVE2D_LATEST_RELEASE_OUTPUT} | grep win64 } > ${LOVE_WIN64_ZIP}; \
	else \
		echo "> win64 archive already exists"; \
	fi

# Extract win64 archive
${LOVE_WIN64_SRC}: ${LOVE_WIN64_ZIP}
	@if [ ! -d ${LOVE_WIN64_SRC} ]; then \
		echo "> Creating directory"; \
		mkdir -p ${LOVE_WIN64_SRC}; \
		echo "> Extracting"; \
		unzip -j ${LOVE_WIN64_ZIP} -d ${LOVE_WIN64_SRC}; \
		echo "> win64 successfully installed in ${LOVE_WIN64_SRC}"; \
	else \
		echo "> win64 source already exists"; \
	fi

# Install Windows 64 dependencies
.PHONY: win64_dep
win64_dep: ${LOVE_WIN64_SRC}

#-- Win32 --#

# Download win32 archive
${LOVE_WIN32_ZIP}: ${LOVE2D_LATEST_RELEASE_OUTPUT}
	@if [ ! -f ${LOVE_WIN32_ZIP} ]; then \
		echo "> Downloading win32 archive"; \
		curl -L ${shell cat ${LOVE2D_LATEST_RELEASE_OUTPUT} | grep win32 } > ${LOVE_WIN32_ZIP}; \
	else \
		echo "> win32 archive already exists"; \
	fi

# Extract win32 archive
${LOVE_WIN32_SRC}: ${LOVE_WIN32_ZIP}
	@if [ ! -d ${LOVE_WIN32_SRC} ]; then \
		echo "> Creating directory"; \
		mkdir -p ${LOVE_WIN32_SRC}; \
		echo "> Extracting"; \
		unzip -j ${LOVE_WIN32_ZIP} -d ${LOVE_WIN32_SRC}; \
		echo "> win32 successfully installed in ${LOVE_WIN32_SRC}"; \
	else \
		echo "> win32 source already exists"; \
	fi

# Install Windows 32 dependencies
.PHONY: win32_dep
win32_dep: ${LOVE_WIN32_SRC}

#-- Nintendo 3DS --#

# Create 3DS dependency directory
${LOVE_3DS_DIR}:
	echo "> Creating directory"
	mkdir -p ${LOVE_3DS_DIR}

# Download LOVEPotion archive
${LOVE_3DS_ZIP}: ${LOVEPOTION_LATEST_RELEASE_OUTPUT} ${LOVE_3DS_DIR}
	@if [ ! -f ${LOVE_3DS_ZIP} ]; then \
		echo "> Downloading Nintendo 3DS archive"; \
		curl -L ${shell cat ${LOVEPOTION_LATEST_RELEASE_OUTPUT} | grep 3DS } > ${LOVE_3DS_ZIP}; \
		chmod +x ${LOVE_3DS_ZIP}; \
	else \
		echo "> 3DS Archive already exists"; \
	fi

# Extract ELF from LOVEPotion archive
${LOVE_3DS}: ${LOVE_3DS_ZIP}
	@if [ ! -f ${LOVE_3DS} ]; then \
		echo "> Extracting ELF"; \
		unzip -p ${LOVE_3DS_ZIP} lovepotion.elf  > ${LOVE_3DS}; \
		echo "> LOVEPotion successfully installed in ${LOVE_3DS}"; \
	else \
		echo "> LOVEPotion ELF already exists"; \
	fi


# Download LOVEPotion bundler assets archive
${LOVE_3DS_ASSETS_ZIP}: ${LOVEPOTION_ASSETS_LATEST_RELEASE_OUTPUT}
	@if [ ! -f ${LOVE_3DS_ASSETS_ZIP} ]; then \
		echo "> Downloading Nintendo 3DS archive"; \
		curl -L ${shell cat ${LOVEPOTION_ASSETS_LATEST_RELEASE_OUTPUT} | grep resources.zip } > ${LOVE_3DS_ASSETS_ZIP}; \
	else \
		echo "> 3DS bunlder assets archive already exists"; \
	fi

# Extract RomFS
${LOVE_3DS_ROMFS}: ${LOVE_3DS_ASSETS_ZIP}
	@if [ ! -f ${LOVE_3DS_ROMFS} ]; then \
		echo "> Extracting RomFS"; \
		unzip -p -j ${LOVE_3DS_ASSETS_ZIP} ctr/files.romfs > ${LOVE_3DS_ROMFS}; \
		echo "> LOVEPotion RomFS successfully installed in ${LOVE_3DS_ROMFS}"; \
	else \
		echo "> LOVEPotion RomFS already exists"; \
	fi

# Download NEST archive
${LOVEPOTION_NEST}: ${LOVE_BINARIES}
	@if [ ! -f ${LOVEPOTION_NEST} ]; then \
		echo "> Downloading LovePotion NEST"; \
		curl -L ${LOVEPOTION_NEST_URL} > ${LOVEPOTION_NEST}; \
	else \
		echo "> NEST archive already exists"; \
	fi

# Install 3DS dependencies
.PHONY: 3ds_dep
3ds_dep: ${LOVE_3DS}

.PHONY: nest_dep
nest_dep: ${LOVEPOTION_NEST}

##-- Utility targets --##

# Remove build files
.PHONY: clean
clean:
	@echo "> Removing build files"
	rm -rf ${BUILD_DIR}
