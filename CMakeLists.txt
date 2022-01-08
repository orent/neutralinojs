cmake_minimum_required(VERSION 3.11)
project(NeutralinoJS)

set(MYARCH x86)
set(MYPLAT linux)
set(NEU_BIN neutralino-${MYPLAT}_${MYARCH})

add_executable(
    ${NEU_BIN}

    resources.cpp 
    helpers.cpp 
    main.cpp 

    server/router.cpp 
    server/neuserver.cpp 

    settings.cpp 
    extensions_loader.cpp 
    chrome.cpp 

    auth/authbasic.cpp 
    auth/permission.cpp 

    lib/tinyprocess/process.cpp 
    lib/tinyprocess/process_unix.cpp 
    lib/easylogging/easylogging++.cc 
    lib/platformfolders/platform_folders.cpp 
    lib/clip/clip.cpp 
    lib/clip/image.cpp 
    lib/clip/clip_x11.cpp 

    api/filesystem/filesystem.cpp 
    api/os/os.cpp 
    api/computer/computer.cpp 
    api/debug/debug.cpp 
    api/storage/storage.cpp 
    api/app/app.cpp 
    api/window/window.cpp 
    api/events/events.cpp 
    api/extensions/extensions.cpp 
    api/clipboard/clipboard.cpp 
)

include(FindPkgConfig)
pkg_check_modules(MODS REQUIRED webkit2gtk-4.0 appindicator3-0.1 xcb)

target_include_directories(
    ${NEU_BIN} 
    PUBLIC
    ${MODS_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/lib
    ${CMAKE_SOURCE_DIR}/lib/asio/include 
)

set(CMAKE_CXX_STANDARD 17)

target_link_libraries(${NEU_BIN} pthread ${MODS_LIBRARIES})

target_compile_options(
    ${NEU_BIN} 
    PUBLIC
    -DELPP_NO_DEFAULT_LOG_FILE=1 
    -DHAVE_XCB_XLIB_H 
    -DASIO_STANDALONE 
    -DWEBVIEW_GTK=1 
    -no-pie 
    -Os 
)

