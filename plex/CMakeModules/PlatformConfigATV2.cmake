# vim: setlocal syntax=cmake:

set(OSX_ARCH armv7)

find_package(OSXSDK)
if(NOT HAVE_IPHONEOS_SDK)
  message(FATAL_ERROR "We need iOS stuff installed")
endif()

######################### Compiler CFLAGS
if(NOT DEFINED IPHONEOS_SDK)
   set(IPHONEOS_SDK ${IPHONEOS_SDK_PATH})
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch ${OSX_ARCH} -miphoneos-version-min=4.2 -isysroot ${IPHONEOS_SDK}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -arch ${OSX_ARCH} -miphoneos-version-min=4.2 -isysroot ${IPHONEOS_SDK}")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -arch ${OSX_ARCH} -miphoneos-version-min=4.2" CACHE STRING "Assembler flags")

include(CheckCSourceCompiles)
CHECK_C_SOURCE_COMPILES("
  int main(int argc, char *argv[])
  {
    return 0;
  }
" BASIC_COMPILE_TEST)

if(NOT BASIC_COMPILE_TEST)
  message(FATAL_ERROR "Compiler failed even the most basic compile test...")
endif()

# We need assembler for ATV2
enable_language(ASM)

# MUST BE ADDED FIRST :)
# This will download our dependency tree
add_subdirectory(plex/Dependencies)

set(CMAKE_REQUIRED_INCLUDES ${dependdir}/include ${root}/lib/ffmpeg)
set(CMAKE_REQUIRED_FLAGS "-D__LINUX_USER__")

######################### Check if we are running within XCode
if(DEFINED XCODE_VERSION)
  message("Building with XCode Generator")
  set(USING_XCODE 1)
endif()

######################### CHECK LIBRARIES / FRAMEWORKS
#### Frameworks for MacOSX
set(osx_frameworks
  AudioToolbox
  CoreAudio
  Foundation
  QuartzCore
  OpenGLES
  CoreMedia
  VideoToolbox
  CoreVideo
  ImageIO
  CFNetwork
  UIKit
)

set(external_libs
  lzo2
  fribidi
  cdio
  freetype
  fontconfig
  sqlite3
  samplerate
  microhttpd
  yajl
  jpeg
  crypto
  tinyxml
  boost_thread
  boost_system
  vorbis
  vorbisenc
  pcre
  pcrecpp
)

set(ffmpeg_libs
  # ffmpeg libraries
  avdevice
  avfilter
  avcodec
  avformat
  postproc
  avutil
  swresample
  swscale
)

if(ENABLE_PYTHON)
  list(APPEND external_libs python2.6)
endif()

set(non_link_libs
  expat
  rtmp
  plist
  shairport
  curl
  FLAC
  modplug
  vorbis
  vorbisfile
  vorbisenc
  ogg
  ass
  mad
  mpeg2
  bluray
  png
  tiff
)

set(system_libs iconv stdc++ bz2 z
)

# go through all the libs we need and find them plus set some good variables
message(STATUS ${dependdir})
foreach(lib ${external_libs})
  plex_find_library(${lib} 0 1 ${dependdir}/lib 1)
endforeach()

# find ffmpeg libs
foreach(lib ${ffmpeg_libs})
  plex_find_library(${lib} 0 1 ${ffmpegdir}/lib 1)
endforeach()

foreach(lib ${non_link_libs})
  plex_find_library(${lib} 0 1 ${dependdir}/lib 0)
endforeach()

foreach(lib ${osx_frameworks})
  plex_find_library(${lib} 1 1 ${IPHONEOS_SDK_PATH}/System/Library/Frameworks 1)
endforeach()

foreach(lib ${system_libs})
  plex_find_library(${lib} 0 1 ${IPHONEOS_SDK_PATH}/usr/lib 1)
endforeach()


#### Deal with some generated files
set(EXECUTABLE_NAME "PlexHomeTheater")

set(ARCH "arm-osx")

set(LIBPATH "${EXECUTABLE_NAME}.frappliance/Frameworks")
set(BINPATH "${EXECUTABLE_NAME}.frappliance/")
set(RESOURCEPATH "${EXECUTABLE_NAME}.frappliance/XBMCData/XBMCHome")
set(FFMPEG_INCLUDE_DIRS ${ffmpegdir}/include)

set(PLEX_LINK_WRAPPED "-arch ${OSX_ARCH} -undefined dynamic_lookup -read_only_relocs suppress -Wl,-alias_list ${root}/xbmc/cores/DllLoader/exports/wrapper_mach_alias")

set(AC_APPLE_UNIVERSAL_BUILD 0)
set(HAVE_LIBEGL 1)
set(HAVE_LIBGLESV2 1)
set(HAVE_VIDEOTOOLBOXDECODER 1)

################## Definitions
add_definitions(-DTARGET_DARWIN -DTARGET_DARWIN_IOS -DTARGET_DARWIN_IOS_ATV2)

unset(COMPRESS_TEXTURES CACHE)
unset(ENABLE_DVD_DRIVE CACHE)

include_directories(
  xbmc/input
  xbmc/windowing
  xbmc/osx/atv2
  xbmc/video
  xbmc/windowing/osx
  xbmc/cores/dvdplayer/DVDCodecs
)

if(NOT ATV2_HOST)
  set(ATV2_HOST office-apple-tv.local)
endif(NOT ATV2_HOST)

if(NOT ATV2_USER)
  set(ATV2_USER root)
endif(NOT ATV2_USER)

add_custom_target(installatv2
  COMMAND rsync -r --progress PlexHomeTheater.frappliance ${ATV2_USER}@${ATV2_HOST}:/Applications
  COMMAND ssh ${ATV2_USER}@${ATV2_HOST} killall AppleTV
  WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}
  DEPENDS install
)
