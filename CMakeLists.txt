cmake_minimum_required(VERSION 3.11)

if(WIN32)
  set(CMAKE_GENERATOR_PLATFORM win32)
elseif(APPLE)
  set(CMAKE_OSX_ARCHITECTURES powerpc CACHE STRING "")     # must be set before project()
else()
  set(CMAKE_CXX_FLAGS_INIT -m32)
  set(CMAKE_EXE_LINKER_FLAGS_INIT -m32)
endif()

project(NeutralinoJS CXX)
set(CMAKE_CXX_STANDARD 17)


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

if(WIN32)
    set(NEU_PLAT win)
    add_compile_options(/Os)
    add_compile_options(/EHsc)
elseif(UNIX)
    add_compile_options(-Os)
    add_compile_options(-Wall)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")            # Not supported by clang
        add_compile_options(-no-pie)
    endif()
endif()

get_cmake_property(_variableNames VARIABLES)
list (SORT _variableNames)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()
