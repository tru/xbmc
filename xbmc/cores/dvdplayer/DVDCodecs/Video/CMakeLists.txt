find_all_sources(. video_SRCS)

list(REMOVE_ITEM video_SRCS ./DVDVideoCodecOpenMax.cpp)
list(REMOVE_ITEM video_SRCS ./OpenMaxVideo.cpp)
list(REMOVE_ITEM video_SRCS ./OpenMax.cpp)

if(NOT HAVE_VIDEOTOOLBOXDECODER)
  list(REMOVE_ITEM video_SRCS ./DVDVideoCodecVideoToolBox.cpp)
endif(NOT HAVE_VIDEOTOOLBOXDECODER)

add_sources(${video_SRCS})