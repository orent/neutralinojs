cmake_minimum_required(VERSION 3.11)
set(CMAKE_OSX_ARCHITECTURES x86_64 CACHE STRING "")

project(NeutralinoJS CXX)
set(CMAKE_CXX_STANDARD 17)

if(UNIX AND NOT APPLE)
include(FindPkgConfig)
endif()

add_library(tinyprocess OBJECT lib/tinyprocess/process.cpp)
if(WIN32)
    target_sources(tinyprocess PRIVATE lib/tinyprocess/process_win.cpp)
else()
    target_sources(tinyprocess PRIVATE lib/tinyprocess/process_unix.cpp)
endif()


add_library(clip OBJECT lib/clip/clip.cpp lib/clip/image.cpp)
if(WIN32)
    target_sources(clip PRIVATE lib/clip/clip_win.cpp)
elseif(APPLE)
    target_sources(clip PRIVATE lib/clip/clip_osx.mm)
    set_source_files_properties(lib/clip/clip_osx.mm PROPERTIES COMPILE_FLAGS -Wno-deprecated-declarations)
else()
    target_sources(clip PRIVATE lib/clip/clip_x11.cpp)
    target_compile_definitions(clip PRIVATE HAVE_XCB_XLIB_H)
    pkg_check_modules(XCB REQUIRED xcb IMPORTED_TARGET)
    target_link_libraries(clip PRIVATE PkgConfig::XCB)
endif()

add_library(asio INTERFACE)
target_include_directories(asio INTERFACE lib/asio/include)
target_compile_definitions(asio INTERFACE ASIO_STANDALONE)

add_library(websocketpp INTERFACE)
target_link_libraries(websocketpp INTERFACE asio)


add_library(easylogging OBJECT lib/easylogging/easylogging++.cc)
target_compile_definitions(easylogging PRIVATE ELPP_NO_DEFAULT_LOG_FILE)

add_executable(neutralino
    main.cpp 
    chrome.cpp 
    extensions_loader.cpp 
    helpers.cpp 
    resources.cpp 
    settings.cpp 
    server/router.cpp 
    server/neuserver.cpp 
    auth/authbasic.cpp 
    auth/permission.cpp 
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

    lib/platformfolders/platform_folders.cpp 
)
set_source_files_properties(api/os/os.cpp PROPERTIES COMPILE_DEFINITIONS OBJC_OLD_DISPATCH_PROTOTYPES)

#pkg_check_modules(MODS REQUIRED webkit2gtk-4.0 appindicator3-0.1)

target_include_directories(
    neutralino 
    PUBLIC
    ${MODS_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/lib
)


target_link_libraries(
	neutralino 
	pthread 
	tinyprocess
	clip
	easylogging
	websocketpp
	${MODS_LIBRARIES}
)

target_compile_options(neutralino PUBLIC -Os)

if(APPLE)
target_link_libraries(
	neutralino 
	"-framework Cocoa"
	"-framework WebKit"
)
endif()

if(UNIX AND NOT APPLE)
target_compile_options(
    neutralino PUBLIC
    -DWEBVIEW_GTK=1 
    -no-pie 
)
endif()

