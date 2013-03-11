add_subdirectory(VideoShaders)
find_all_sources(. videorenderers_SRCS)

if(NOT TARGET_ATV2)
  list(REMOVE_ITEM videorenderers_SRCS ./LinuxRendererGLES.cpp)
else(NOT TARGET_ATV2)
  list(APPEND videorenderers_SRCS ./yuv2rgb.neon.S)
endif(NOT TARGET_ATV2)

if(NOT TARGET_WINDOWS)
  list(REMOVE_ITEM videorenderers_SRCS ./WinRenderer.cpp)
  list(REMOVE_ITEM videorenderers_SRCS ./OverlayRendererDX.cpp)
else()
  list(REMOVE_ITEM videorenderers_SRCS ./LinuxRendererGL.cpp)
endif()

add_sources(${videorenderers_SRCS})
