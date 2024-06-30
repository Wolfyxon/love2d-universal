###==-- Data --==###

##-- Game data --##
EXE_NAME    := "LovebrewTest"
TITLE 	    := "3DS Lovebrew test"
DESCRIPTION := "Test 3DS app using Love potion"
AUTHOR      := "Epic person"
VERSION     := "1.0"
ICON        := "icon.png"

##-- Directories --##
BUILD_DIR  := "build"
SOURCE_DIR := "src"

##-- Uncategorized files --##
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
LOVE_WIN64_OUT      := ${LOVE_WIN64_BUILD}/love.exe

LOVE_WIN32_SRC      := ${LOVE_BINARIES}/win32
LOVE_WIN32_IN       := ${LOVE_WIN32_SRC}/love.exe
LOVE_WIN32_ZIP      := ${LOVE_BINARIES}/win32.zip
LOVE_WIN32_BUILD    := ${BUILD_DIR}/win32
LOVE_WIN32_OUT      := ${LOVE_WIN32_BUILD}/love.exe

LOVE_3DS            := ${LOVE_BINARIES}/lovepotion.elf

##-- Software --##
LOVE          := love
APPIMAGETOOL  := appimagetool
#- Nintendo 3DS -#
3DS_EMULATOR  := citra
DKP_TOOLS     := /opt/devkitpro/tools/bin
SMDHTOOL      := ${DKP_TOOLS}/smdhtool
3DSXTOOL      := ${DKP_TOOLS}/3dsxtool

##- Dependency links and output files -##
LOVE2D_LATEST_RELEASE        := https://api.github.com/repos/love2d/love/releases/latest
LOVE2D_LATEST_RELEASE_OUTPUT := /tmp/love2d_latest_release

###==-- Targets --==###

##-- Build & testing targets --##

#- Universal PC -#

${LOVE_OUT}: ${BUILD_DIR}
	@echo "> Removing old .love file to prevent adding files"
	rm -f ${LOVE_OUT}

	@echo "> Creating .love file"
	cd ${SOURCE_DIR} && zip -9 -r ../${LOVE_OUT} *

.PHONY: love
love: ${LOVE_OUT}

.PHONY: run
run:
	@echo "> Running the source directory with LOVE"
	${LOVE} ${SOURCE_DIR}

#- Linux -#

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

.PHONY: win64
win64: ${LOVE_WIN64_SRC} ${LOVE_OUT}
	@echo "> Copying love source into build"
	cp -r ${LOVE_WIN64_SRC} ${LOVE_WIN64_BUILD}

	@echo "> Embedding game into the executable"
	cat ${LOVE_WIN64_IN} ${LOVE_OUT} > ${LOVE_WIN64_OUT}

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

${BUILD_DIR}:
	@echo "> Creating build directory"
	-mkdir -p ${BUILD_DIR}

#- Nintendo 3DS -#

# Compile 3DSX
# TODO: image to t3x conversion 
${BUILD_DIR}/${EXE_NAME}.3dsx: ${BUILD_DIR}/${EXE_NAME}.smdh
	@echo "> Compiling 3DSX file"
	${3DSXTOOL} ${LOVE_3DS} ${BUILD_DIR}/${EXE_NAME}.3dsx --smdh=${BUILD_DIR}/${EXE_NAME}.smdh --romfs=${SOURCE_DIR}
 
# Compile SMDH
${BUILD_DIR}/${EXE_NAME}.smdh: ${BUILD_DIR}
	@echo "> Compiling SMDH file"
	${SMDHTOOL} --create ${TITLE} ${DESCRIPTION} ${AUTHOR} ${ICON} ${BUILD_DIR}/${EXE_NAME}.smdh

##-- Dependency targets --##

# Prepare directory
${LOVE_BINARIES}:
	@echo "> Creating directory"
	mkdir -p ${LOVE_BINARIES}

# Fetch build URLs
${LOVE2D_LATEST_RELEASE_OUTPUT}: ${LOVE_BINARIES}
	@if [ ! -f ${LOVE_WIN64_ZIP} ]; then \
		echo "> Fetching love2d builds"; \
		curl -s ${LOVE2D_LATEST_RELEASE} | grep browser_download_url | sed -n 's/.*"browser_download_url": "\(.*\)"/\1/p' > ${LOVE2D_LATEST_RELEASE_OUTPUT}; \
		cat ${LOVE2D_LATEST_RELEASE_OUTPUT}; \
	else \
		echo "> Builds already fetched"; \
	fi

#-- Linux --#

# Download Linux AppImage
${LOVE_LINUX_APPIMAGE_IN}: ${LOVE2D_LATEST_RELEASE_OUTPUT}
	@if [ ! -f ${LOVE_LINUX_APPIMAGE_IN} ]; then \
		echo "> Downloading Linux AppImage"; \
		curl -L ${shell cat ${LOVE2D_LATEST_RELEASE_OUTPUT} | grep AppImage } > ${LOVE_LINUX_APPIMAGE_IN}; \
		chmod +x ${LOVE_LINUX_APPIMAGE_IN}
	else \
		echo "> Linux AppImage already exists"; \
	fi


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

.PHONY: win32_dep
win32_dep: ${LOVE_WIN32_SRC}

##-- Utility targets --##

# Remove build files
.PHONY: clean
clean:
	@echo "> Removing build files"
	rm -rf ${BUILD_DIR}
