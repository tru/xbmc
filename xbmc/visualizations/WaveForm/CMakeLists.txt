set(TARGET_NAME waveform)
if(TARGET_WIN32)
  set(TARGET_NAME waveform_win32)
endif(TARGET_WIN32)

if(TARGET_ATV2)
  add_library(${TARGET_NAME} MODULE Main_gles.cpp)
  target_link_libraries(${TARGET_NAME} ${CONFIG_LIBRARY_OPENGLES} eglhelpers)
else(TARGET_ATV2)
  add_library(${TARGET_NAME} MODULE Main.cpp)
  target_link_libraries(${TARGET_NAME} ${CONFIG_LIBRARY_OPENGL})
endif(TARGET_ATV2)

install(TARGETS ${TARGET_NAME} LIBRARY DESTINATION ${RESOURCEPATH}/addons/visualization.waveform COMPONENT RUNTIME)
