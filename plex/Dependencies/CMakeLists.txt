set(DEPEND_ARGS osx)

if(TARGET_OSX)
  if(TARGET_ARCH STREQUAL "x86_64")
    set(DEPEND_ARGS osx64)
  endif()
elseif(TARGET_ATV2)
  set(DEPEND_ARGS ios)
endif()

execute_process(
  COMMAND ${plexdir}/scripts/fetch-depends.sh ${DEPEND_ARGS}
  WORKING_DIRECTORY ${root}
  RESULT_VARIABLE result
)

if(DEPEND_ARGS STREQUAL ios)
  set(NATIVE_ARGS osx)
  if(NATIVE_ARCH STREQUAL "x86_64")
    set(NATIVE_ARGS_ARGS osx64)
  endif(NATIVE_ARCH STREQUAL "x86_64")
  # we need native depends as well...
  execute_process(
    COMMAND ${plexdir}/scripts/fetch-depends.sh ${NATIVE_ARGS}
    WORKING_DIRECTORY ${root}
    RESULT_VARIABLE result
  )
endif(DEPEND_ARGS STREQUAL ios)  

if(result)
  message(FATAL_ERROR "Fetch depends returned ${result}")
endif(result)

find_program(GIT_PATH git HINTS /usr/bin /usr/local/bin)
if(GIT_PATH MATCHES "NOTFOUND")
  message(WARNING "git not found! we might have problem..")
endif()

execute_process(
  COMMAND ${GIT_PATH} rev-list -1 HEAD -- ${PROJECT_SOURCE_DIR}/tools/darwin/depends
  COMMAND cut -c1-8
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  OUTPUT_VARIABLE DEPEND_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
  COMMAND ${GIT_PATH} rev-list -1 HEAD -- ${PROJECT_SOURCE_DIR}/lib/ffmpeg
  COMMAND cut -c1-8
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  OUTPUT_VARIABLE FFMPEG_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

unset(dependdir CACHE)
unset(ffmpegdir CACHE)
unset(dependdir_native CACHE)
unset(ffmpegdir_native CACHE)


if(TARGET_OSX)
  set(dependdir ${plexdir}/Dependencies/macosx${OSX_SDK_VERSION}_${TARGET_ARCH}-xbmc-${DEPEND_HASH} CACHE STRING "path to dependencies")
  set(ffmpegdir ${plexdir}/Dependencies/macosx${OSX_SDK_VERSION}_${TARGET_ARCH}-ffmpeg-${FFMPEG_HASH} CACHE STRING "path to ffmpeg")
  set(dependdir_native ${plexdir}/Dependencies/macosx${OSX_SDK_VERSION}_${NATIVE_ARCH}-xbmc-${DEPEND_HASH} CACHE STRING "path to native dependencies")
  set(ffmpegdir_native ${plexdir}/Dependencies/macosx${OSX_SDK_VERSION}_${NATIVE_ARCH}-ffmpeg-${FFMPEG_HASH} CACHE STRING "path to native ffmpeg")
elseif(TARGET_ATV2)
  set(dependdir_native ${plexdir}/Dependencies/macosx${OSX_SDK_VERSION}_${NATIVE_ARCH}-xbmc-${DEPEND_HASH} CACHE STRING "path to native dependencies")
  set(ffmpegdir_native ${plexdir}/Dependencies/macosx${OSX_SDK_VERSION}_${NATIVE_ARCH}-ffmpeg-${FFMPEG_HASH} CACHE STRING "path to native ffmpeg")
  set(dependdir ${plexdir}/Dependencies/iphoneos${IPHONEOS_SDK_VERSION}_armv7-xbmc-${DEPEND_HASH} CACHE STRING "path to dependencies")
  set(ffmpegdir ${plexdir}/Dependencies/iphoneos${IPHONEOS_SDK_VERSION}_armv7-ffmpeg-${FFMPEG_HASH} CACHE STRING "path to ffmpeg")
endif()

message(STATUS "dependdir ${dependdir} native ${dependdir_native}")

if(NOT IS_DIRECTORY ${dependdir})
  message(FATAL_ERROR "Dependency directory ${dependdir} not created!")
endif(NOT IS_DIRECTORY ${dependdir})

if(NOT IS_DIRECTORY ${ffmpegdir})
  message(FATAL_ERROR "Dependency directory ${ffmpegdir} not created!")
endif(NOT IS_DIRECTORY ${ffmpegdir})


if(NOT TARGET_ATV2)
  file(COPY ${root}/tools/darwin/depends/libcrystalhd/libcrystalhd DESTINATION ${dependdir}/include)
endif(NOT TARGET_ATV2)
