cmake_minimum_required(VERSION 3.11)
set(CMAKE_OSX_ARCHITECTURES x86_64 CACHE STRING "")
project(NeutralinoJS CXX)
set(CMAKE_CXX_STANDARD 17)

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
)
if(APPLE)
    set_source_files_properties(
        api/os/os.cpp PROPERTIES COMPILE_DEFINITIONS OBJC_OLD_DISPATCH_PROTOTYPES)
endif()

target_include_directories(neutralino PUBLIC .)

target_link_libraries(neutralino 
    pthread 
    tinyprocess
    clip
    easylogging
    websocketpp
    tray
    webview
    platformfolders
)


if(UNIX AND NOT APPLE)
    include(FindPkgConfig)
    add_compile_options(-no-pie)
endif()
add_compile_options(-Os)


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
    set_source_files_properties(lib/clip/clip_osx.mm PROPERTIES COMPILE_OPTIONS  -Wno-deprecated-declarations)
else()
    target_sources(clip PRIVATE lib/clip/clip_x11.cpp)
    pkg_check_modules(XCB REQUIRED IMPORTED_TARGET xcb)
    target_link_libraries(clip PRIVATE PkgConfig::XCB)
    target_compile_definitions(clip PRIVATE HAVE_XCB_XLIB_H)
endif()



add_library(asio INTERFACE)
target_include_directories(asio INTERFACE lib/asio/include)
target_compile_definitions(asio INTERFACE ASIO_STANDALONE)



add_library(websocketpp INTERFACE)
target_include_directories(websocketpp INTERFACE lib)
target_link_libraries(websocketpp INTERFACE asio)
if(WIN32)
    target_compile_definitions(websocketpp _WEBSOCKETPP_CPP11_STL_)
endif()



add_library(tray INTERFACE)
if(UNIX AND NOT APPLE)
    pkg_check_modules(APPINDICATOR3 REQUIRED IMPORTED_TARGET appindicator3-0.1)
    target_link_libraries(tray INTERFACE PkgConfig::APPINDICATOR3)
endif()



add_library(webview INTERFACE)
if(WIN32)
    add_library(webview2loader SHARED IMPORTED)
    set_target_property(webview2loader PROPERTY IMPORTED_LOCATION webview/windows/WebView2Loader.dll.lib)
    target_link_libraries(webview INTERFACE webview2loader)
elseif(APPLE)
    target_link_libraries(webview INTERFACE "-framework Cocoa" "-framework WebKit")
elseif(UNIX)
    pkg_check_modules(WEBKIT2GTK REQUIRED IMPORTED_TARGET webkit2gtk-4.0)
    target_link_libraries(webview INTERFACE PkgConfig::WEBKIT2GTK)
endif()



add_library(easylogging OBJECT lib/easylogging/easylogging++.cc)
target_compile_definitions(easylogging PRIVATE ELPP_NO_DEFAULT_LOG_FILE)



add_library(platformfolders OBJECT lib/platformfolders/platform_folders.cpp)
