cmake_minimum_required(VERSION 3.11)
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
    set_source_files_properties(api/os/os.cpp 
        PROPERTIES COMPILE_DEFINITIONS OBJC_OLD_DISPATCH_PROTOTYPES
    )
endif()

target_include_directories(neutralino PRIVATE .)

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
    add_compile_options(/Os)
    add_compile_options(/EHsc)
elseif(UNIX)    # Includes APPLE
    add_compile_options(-Os)
    add_compile_options(-Wall)
    if(NOT APPLE)
        set_target_properties(neutralino PROPERTIES POSITION_INDEPENDENT_CODE OFF)
    endif()
else()
    message(FATAL_ERROR "Unsupported platform ${CMAKE_CXX_PLATFORM_ID}")
endif()


string(TOLOWER ${CMAKE_SYSTEM_NAME} NEU_PLAT)
string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} NEU_ARCH)

if(APPLE AND DEFINED CMAKE_OSX_ARCHITECTURES)
    # Overide with first item in list (presumably arm64):
    list(GET CMAKE_OSX_ARCHITECTURES 0 NEU_ARCH) 
endif()
if(WIN32 AND DEFINED CMAKE_CXX_COMPILER_ARCHITECTURE_ID)
    # Overide with compiler target arch (presumably X86):
    string(TOLOWER ${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} NEU_ARCH)
endif()

# Match names used by build_* scripts:
if(${NEU_PLAT} STREQUAL darwin)
    set(NEU_PLAT mac)
elseif(${NEU_PLAT} STREQUAL windows)
    set(NEU_PLAT win)
endif()
if(${NEU_ARCH} STREQUAL x86_64 OR ${NEU_ARCH} STREQUAL amd64)
    set(NEU_ARCH x64)
elseif(${NEU_ARCH} STREQUAL x86)
    set(NEU_ARCH i386)
endif()

set_target_properties(neutralino PROPERTIES 
    RUNTIME_OUTPUT_DIRECTORY bin
    OUTPUT_NAME neutralino-${NEU_PLAT}_${NEU_ARCH}
)
