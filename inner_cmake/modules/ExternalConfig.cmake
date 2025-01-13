macro(__find_outer_external_libs)
    # Find and configure boost
    if(SLIC3R_STATIC)
        # Use static boost libraries.
        set(Boost_USE_STATIC_LIBS ON)
        # Use boost libraries linked statically to the C++ runtime.
        # set(Boost_USE_STATIC_RUNTIME ON)
    endif()
    #set(Boost_DEBUG ON)
    # set(Boost_COMPILER "-mgw81")
    # boost::process was introduced first in version 1.64.0,
    # boost::beast::detail::base64 was introduced first in version 1.66.0
    set(MINIMUM_BOOST_VERSION "1.83.0")
    set(_boost_components "system;filesystem;thread;log;locale;regex;chrono;atomic;date_time;iostreams;nowide")
    find_package(Boost ${MINIMUM_BOOST_VERSION} REQUIRED COMPONENTS ${_boost_components})

    add_library(boost_libs INTERFACE)
    add_library(boost_headeronly INTERFACE)

    if (APPLE)
        # BOOST_ASIO_DISABLE_KQUEUE : prevents a Boost ASIO bug on OS X: https://svn.boost.org/trac/boost/ticket/5339
        target_compile_definitions(boost_headeronly INTERFACE BOOST_ASIO_DISABLE_KQUEUE)
    endif()

    if(NOT SLIC3R_STATIC)
        target_compile_definitions(boost_headeronly INTERFACE BOOST_LOG_DYN_LINK)
    endif()

    if(TARGET Boost::system)
        message(STATUS "Boost::boost exists")
        target_link_libraries(boost_headeronly INTERFACE Boost::boost)

        # Only from cmake 3.12
        # list(TRANSFORM _boost_components PREPEND Boost:: OUTPUT_VARIABLE _boost_targets)
        set(_boost_targets "")
        foreach(comp ${_boost_components})
            list(APPEND _boost_targets "Boost::${comp}")
        endforeach()

        target_link_libraries(boost_libs INTERFACE
            boost_headeronly # includes the custom compile definitions as well
            ${_boost_targets}
            )
        slic3r_remap_configs("${_boost_targets}" RelWithDebInfo Release)
    else()
        target_include_directories(boost_headeronly INTERFACE ${Boost_INCLUDE_DIRS})
        target_link_libraries(boost_libs INTERFACE boost_headeronly ${Boost_LIBRARIES})
    endif()

    find_package(Eigen3 CONFIG REQUIRED)

    # Find and configure intel-tbb
    if(SLIC3R_STATIC)
        set(TBB_STATIC 1)
    endif()
    set(TBB_DEBUG 1)
    find_package(TBB CONFIG REQUIRED)
    slic3r_remap_configs(TBB::tbb RelWithDebInfo Release)
    slic3r_remap_configs(TBB::tbbmalloc RelWithDebInfo Release)
    # include_directories(${TBB_INCLUDE_DIRS})
    # add_definitions(${TBB_DEFINITIONS})
    # if(MSVC)
    #     # Suppress implicit linking of the TBB libraries by the Visual Studio compiler.
    #     add_definitions(-D__TBB_NO_IMPLICIT_LINKAGE)
    # endif()
    # The Intel TBB library will use the std::exception_ptr feature of C++11.
    # add_definitions(-DTBB_USE_CAPTURED_EXCEPTION=0)

    # find_package(CURL REQUIRED)

    # add_library(libcurl INTERFACE)
    # target_link_libraries(libcurl INTERFACE CURL::libcurl)

    # # Fixing curl's cmake config script bugs
    # if (NOT WIN32)
    #     # Required by libcurl
    #     find_package(ZLIB REQUIRED)
    #     target_link_libraries(libcurl INTERFACE ZLIB::ZLIB)
    # else()
    #     target_link_libraries(libcurl INTERFACE crypt32)
    # endif()

    # ## OPTIONAL packages

    # Find expat. We have our overriden FindEXPAT which exports libexpat target
    # no matter what.
    find_package(EXPAT REQUIRED)

    add_library(libexpat INTERFACE)

    if (TARGET EXPAT::EXPAT ) # found by a newer Find script
        target_link_libraries(libexpat INTERFACE EXPAT::EXPAT)
    elseif(TARGET expat::expat) # found by a config script
        target_link_libraries(libexpat INTERFACE expat::expat)
    else() # found by an older Find script
        target_link_libraries(libexpat INTERFACE ${EXPAT_LIBRARIES})
    endif ()

    find_package(PNG CONFIG REQUIRED)

    # find_package(JPEG CONFIG REQUIRED)
    find_package(libjpeg-turbo CONFIG REQUIRED)
    add_library(JPEG::JPEG ALIAS libjpeg-turbo::libjpeg-turbo)

    set(OpenGL_GL_PREFERENCE "LEGACY")
    find_package(OpenGL REQUIRED)

    # Find glew or use bundled version
    if (SLIC3R_STATIC AND NOT SLIC3R_STATIC_EXCLUDE_GLEW)
        set(GLEW_USE_STATIC_LIBS ON)
        set(GLEW_VERBOSE ON)
    endif()

    find_package(GLEW CONFIG REQUIRED)

    # Find the Cereal serialization library
    find_package(cereal REQUIRED)
    add_library(libcereal INTERFACE)
    if (NOT TARGET cereal::cereal)
        target_link_libraries(libcereal INTERFACE cereal)
    else()
        target_link_libraries(libcereal INTERFACE cereal::cereal)
    endif()  

    find_package(NLopt CONFIG REQUIRED)
    slic3r_remap_configs(NLopt::nlopt RelWithDebInfo Release)
    
    find_package(NanoSVG CONFIG REQUIRED)
    add_library(NanoSVG::nanosvg ALIAS nanosvg::nanosvg)
    add_library(NanoSVG::nanosvgrast ALIAS nanosvg::nanosvg)
    
    # if(SLIC3R_STATIC)
    #     set(OPENVDB_USE_STATIC_LIBS ON)
    #     set(USE_BLOSC TRUE)
    # endif ()
    
    # find_package(OpenVDB 5.0 COMPONENTS openvdb)
    # if(OpenVDB_FOUND)
    #     slic3r_remap_configs(IlmBase::Half RelWithDebInfo Release)
    #     slic3r_remap_configs(Blosc::blosc RelWithDebInfo Release)
    # else ()
    #     message(FATAL_ERROR "OpenVDB could not be found with the bundled find module. "
    #                    "You can try to specify the find module location of your "
    #                    "OpenVDB installation with the OPENVDB_FIND_MODULE_PATH cache variable.")
    # endif ()

    find_package(Qhull CONFIG REQUIRED)
    add_library(qhull INTERFACE)
    if(SLIC3R_STATIC)
        slic3r_remap_configs("Qhull::qhullcpp;Qhull::qhullstatic_r" RelWithDebInfo Release)
        target_link_libraries(qhull INTERFACE Qhull::qhullcpp Qhull::qhullstatic_r)
    else()
        slic3r_remap_configs("Qhull::qhullcpp;Qhull::qhull_r" RelWithDebInfo Release)
        target_link_libraries(qhull INTERFACE Qhull::qhullcpp Qhull::qhull_r)
    endif()

    find_package(Catch2 CONFIG REQUIRED)
    # include(Catch)
endmacro()

macro(__find_gui_external_libs)
    # if(WIN32)
    #     message(STATUS "WXWIN environment set to: $ENV{WXWIN}")
    # elseif(UNIX)
    #     set(wxWidgets_USE_UNICODE ON)
    #     if(SLIC3R_STATIC)
    #         set(wxWidgets_USE_STATIC ON)
    #     else()
    #         set(wxWidgets_USE_STATIC OFF)
    #     endif()
    # endif()

    # if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    #     set (wxWidgets_CONFIG_OPTIONS "--toolkit=gtk${SLIC3R_GTK}")
    # endif ()
    # find_package(wxWidgets 3.2 MODULE REQUIRED COMPONENTS base core adv html gl webview)

    # include(${wxWidgets_USE_FILE})

    # slic3r_remap_configs(wx::wxhtml wx::wxadv wx::wxgl wx::wxcore wx::wxbase RelWithDebInfo Release)

    # if(UNIX)
    #     message(STATUS "wx-config path: ${wxWidgets_CONFIG_EXECUTABLE}")
    # endif()

    # string(REGEX MATCH "wxpng" WX_PNG_BUILTIN ${wxWidgets_LIBRARIES})
    # if (PNG_FOUND AND NOT WX_PNG_BUILTIN)
    #     list(FILTER wxWidgets_LIBRARIES EXCLUDE REGEX png)
    #     list(APPEND wxWidgets_LIBRARIES ${PNG_LIBRARIES})
    # endif ()

    # string(REGEX MATCH "wxjpeg" WX_JPEG_BUILTIN ${wxWidgets_LIBRARIES})
    # if (JPEG_FOUND AND NOT WX_JPEG_BUILTIN)
    #     list(FILTER wxWidgets_LIBRARIES EXCLUDE REGEX jpeg)
    #     list(APPEND wxWidgets_LIBRARIES ${JPEG_LIBRARIES})
    # endif ()

    # string(REGEX MATCH "wxexpat" WX_EXPAT_BUILTIN ${wxWidgets_LIBRARIES})
    # if (EXPAT_FOUND AND NOT WX_EXPAT_BUILTIN)
    #     list(FILTER wxWidgets_LIBRARIES EXCLUDE REGEX expat)
    #     list(APPEND wxWidgets_LIBRARIES libexpat)
    # endif ()

    # # This is an issue in the new wxWidgets cmake build, doesn't deal with librt
    # find_library(LIBRT rt)
    # if(LIBRT)
    #     list(APPEND wxWidgets_LIBRARIES ${LIBRT})
    # endif()

    # # This fixes a OpenGL linking issue on OSX. wxWidgets cmake build includes
    # # wrong libs for opengl in the link line and it does not link to it by himself.
    # # libslic3r_gui will link to opengl anyway, so lets override wx
    # list(FILTER wxWidgets_LIBRARIES EXCLUDE REGEX OpenGL)

    # if (UNIX AND NOT APPLE)
    #     list(APPEND wxWidgets_LIBRARIES X11 wayland-client wayland-egl EGL)
    # endif ()
    # #    list(REMOVE_ITEM wxWidgets_LIBRARIES oleacc)
    # message(STATUS "wx libs: ${wxWidgets_LIBRARIES}")

    # if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    #     find_package(OpenSSL REQUIRED)
    # endif()
endmacro()

macro(__find_libslic3r_external_libs)
    find_package(LibBGCode REQUIRED COMPONENTS Convert)
    slic3r_remap_configs(LibBGCode::bgcode_core RelWithDebInfo Release)
    slic3r_remap_configs(LibBGCode::bgcode_binarize RelWithDebInfo Release)
    slic3r_remap_configs(LibBGCode::bgcode_convert RelWithDebInfo Release)

    cmake_policy(PUSH)
    cmake_policy(SET CMP0011 NEW)
    find_package(CGAL REQUIRED)
    cmake_policy(POP)

    # find_package(JPEG REQUIRED)
endmacro()

macro(__find_opencascade_external_lib)
    # find_package(OpenCASCADE 7.6.1 REQUIRED)

    # set(OCCT_LIBS
    #     TKXDESTEP
    #     TKSTEP
    #     TKSTEP209
    #     TKSTEPAttr
    #     TKSTEPBase
    #     TKXCAF
    #     TKXSBase
    #     TKVCAF
    #     TKCAF
    #     TKLCAF
    #     TKCDF
    #     TKV3d
    #     TKService
    #     TKMesh
    #     TKBO
    #     TKPrim
    #     TKHLR
    #     TKShHealing
    #     TKTopAlgo
    #     TKGeomAlgo
    #     TKBRep
    #     TKGeomBase
    #     TKG3d
    #     TKG2d
    #     TKMath
    #     TKernel
    # )

    # slic3r_remap_configs("${OCCT_LIBS}" RelWithDebInfo Release)
endmacro()

