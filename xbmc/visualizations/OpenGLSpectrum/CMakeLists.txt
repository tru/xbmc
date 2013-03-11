find_all_sources(. OGL_SRC)
add_library(opengl_spectrum MODULE ${OGL_SRC})

if(TARGET_ATV2)
  target_link_libraries(opengl_spectrum eglhelpers ${CONFIG_LIBRARY_OPENGLES})
else(TARGET_ATV2)
  target_link_libraries(opengl_spectrum ${CONFIG_LIBRARY_OPENGL})
endif(TARGET_ATV2)

install(TARGETS opengl_spectrum DESTINATION ${RESOURCEPATH}/addons/visualization.glspectrum COMPONENT RUNTIME)
