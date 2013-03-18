set(SRC md5.cpp SDL_anigif.cpp XBTFWriter.cpp XBMCTex.cpp ${root}/xbmc/guilib/XBTF.cpp)
if(TARGET_WIN32)
  set(SRC ${SRC} Win32/dirent.c Win32/dirent.h)
endif(TARGET_WIN32)

include_directories(${dependdir_native}/include ${root}/lib ${root}/xbmc ${CMAKE_BINARY_DIR}/xbmc ${root}/xbmc/linux)

set(CMAKE_C_FLAGS "-arch ${NATIVE_ARCH}")
set(CMAKE_CXX_FLAGS "-arch ${NATIVE_ARCH}")

if(CMAKE_SSE_CFLAGS)
  add_definitions(-DSQUISH_USE_SSE=2)

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_SSE_CFLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_SSE_CFLAGS}")

  if(CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_C_FLAGS_DEBUG "-O3")
    set(CMAKE_CXX_FLAGS_DEBUG "-O3")
  elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_C_FLAGS_DEBUG "/O2")
    set(CMAKE_CXX_FLAGS_DEBUG "/O2")
  endif(CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "GNU")

endif(CMAKE_SSE_CFLAGS)

if(TARGET_WIN32)
  include_directories(Win32)
endif(TARGET_WIN32)

# plex_find_library lib framework nodefaultpath searchpath addtolinklist
#find_library(NATIVE_SDL SDL PATHS ${dependdir_native}/lib NO_DEFAULT_PATH)
find_library(NATIVE_SDL_IMAGE SDL_image PATHS ${dependdir_native}/lib NO_DEFAULT_PATH)
find_library(NATIVE_LZO2 lzo2 PATHS ${dependdir_native}/lib NO_DEFAULT_PATH)

add_definitions(-DUSE_LZO_PACKING)
add_executable(TexturePacker ${SRC})
target_link_libraries(TexturePacker
#  ${NATIVE_SDL}
  ${NATIVE_SDL_IMAGE}
  lib_squish-${NATIVE_ARCH}
)

if(NOT TARGET_WIN32)
  target_link_libraries(TexturePacker ${NATIVE_LZO2})
else(NOT TARGET_WIN32)
  find_library(LIB_LZO lzo ${root}/lib/win32/liblzo)
  target_link_libraries(TexturePacker ${LIB_LZO})
endif(NOT TARGET_WIN32)
