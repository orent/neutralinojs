if(UNIX AND NOT APPLE)
    include(FindPkgConfig)
endif()


add_library(tinyprocess OBJECT tinyprocess/process.cpp)
if(WIN32)
    target_sources(tinyprocess PRIVATE tinyprocess/process_win.cpp)
else()
    target_sources(tinyprocess PRIVATE tinyprocess/process_unix.cpp)
endif()


add_library(clip OBJECT clip/clip.cpp clip/image.cpp)
if(WIN32)
    target_sources(clip PRIVATE clip/clip_win.cpp)
elseif(APPLE)
    target_sources(clip PRIVATE clip/clip_osx.mm)
    set_source_files_properties(clip/clip_osx.mm PROPERTIES COMPILE_OPTIONS  -Wno-deprecated-declarations)
else()
    target_sources(clip PRIVATE clip/clip_x11.cpp)
    pkg_check_modules(XCB REQUIRED IMPORTED_TARGET xcb)
    target_link_libraries(clip PRIVATE PkgConfig::XCB)
    target_compile_definitions(clip PRIVATE HAVE_XCB_XLIB_H)
endif()


add_library(easylogging OBJECT easylogging/easylogging++.cc)
target_compile_definitions(easylogging PRIVATE ELPP_NO_DEFAULT_LOG_FILE)


add_library(platformfolders OBJECT platformfolders/platform_folders.cpp)


add_library(asio INTERFACE)
target_include_directories(asio INTERFACE asio/include)
target_compile_definitions(asio INTERFACE ASIO_STANDALONE)


add_library(websocketpp INTERFACE)
target_include_directories(websocketpp INTERFACE .)
target_link_libraries(websocketpp INTERFACE asio)
if(WIN32)
    target_compile_definitions(websocketpp INTERFACE _WEBSOCKETPP_CPP11_STL_)
endif()


add_library(tray INTERFACE)
if(UNIX AND NOT APPLE)
    pkg_check_modules(APPINDICATOR REQUIRED IMPORTED_TARGET appindicator3-0.1)
    target_link_libraries(tray INTERFACE PkgConfig::APPINDICATOR)
endif()


add_library(webview INTERFACE)
if(WIN32)
    add_library(webview2loader SHARED IMPORTED)
    set_target_properties(webview2loader PROPERTIES IMPORTED_LOCATION webview/windows/WebView2Loader.dll.lib)
    target_link_libraries(webview INTERFACE webview2loader)
elseif(APPLE)
    target_link_libraries(webview INTERFACE "-framework Cocoa" "-framework WebKit")
elseif(UNIX)
    pkg_check_modules(WEBKIT2GTK REQUIRED IMPORTED_TARGET webkit2gtk-4.0)
    target_link_libraries(webview INTERFACE PkgConfig::WEBKIT2GTK)
endif()

