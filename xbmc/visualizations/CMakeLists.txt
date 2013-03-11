set(CMAKE_SHARED_MODULE_SUFFIX ".vis")
set(CMAKE_SHARED_MODULE_PREFIX "")

if(NOT WIN32 AND NOT TARGET_ATV2)
  add_definitions(-DHAS_SDL -DHAS_SDL_OPENGL)
elseif(TARGET_ATV2)
  add_definitions(-DHAS_GLES)
endif(NOT WIN32 AND NOT TARGET_ATV2)

if(TARGET_ATV2)
  include_directories(EGLHelpers)
  add_subdirectory(EGLHelpers)
endif(TARGET_ATV2)

add_subdirectory(WaveForm)

if(NOT WIN32)
  add_subdirectory(OpenGLSpectrum)

  if(NOT TARGET_ATV2)
    add_subdirectory(XBMCProjectM)
  endif(NOT TARGET_ATV2)
  
  if(NOT TARGET_COMMON_DARWIN)
    add_subdirectory(Goom)
  endif()
else()
  add_subdirectory(Milkdrop)
  add_subdirectory(DirectXSpectrum)
endif()
