cmake_minimum_required(VERSION 3.11)
set(CMAKE_OSX_ARCHITECTURES x86_64 CACHE STRING "")     # must be set before project()
project(NeutralinoJS CXX)
set(CMAKE_CXX_STANDARD 17)

if(UNIX)
    add_compile_options(-Os)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")            # Not supported by clang
        add_compile_options(-no-pie)
    endif()
elseif(WIN32)
    add_compile_options(/Os)
    add_compile_options(/EHsc)
endif()

add_subdirectory(lib)

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
