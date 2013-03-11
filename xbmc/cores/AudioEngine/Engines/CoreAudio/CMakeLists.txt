
if(TARGET_OSX)
  find_all_sources(. ae_SRCS)
else()
  set(ae_SRCS
    CoreAudioAE.cpp
    CoreAudioAEHAL.cpp
    CoreAudioAEHALIOS.cpp
    CoreAudioAEHALOSX.cpp
    CoreAudioAESound.cpp
    CoreAudioAEStream.cpp
    CoreAudioRingBuffer.h
    ICoreAudioAEHAL.h
    ICoreAudioSource.h
  )
endif()

add_sources(${ae_SRCS})
