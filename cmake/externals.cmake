# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

include(ExternalProject)

get_filename_component(GIT_PATH ${GIT_EXECUTABLE} PATH)
find_program(PATCH_EXECUTABLE patch HINTS "${GIT_PATH}" "${GIT_PATH}/../bin")
if (NOT PATCH_EXECUTABLE)
   message(FATAL_ERROR "patch not found")
endif()

set_property(DIRECTORY PROPERTY EP_BASE "${CMAKE_BINARY_DIR}/ep_base")

if(INCLUDE_SANDBOX)
    set(PLUGIN_LOADER ${PLUGIN_LOADER} "github.com/mozilla-services/heka/sandbox/plugins")
    set(SANDBOX_PACKAGE "lua_sandbox")
    set(SANDBOX_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${PROJECT_PATH} -DLUA_JIT=off --no-warn-unused-cli)
    externalproject_add(
        ${SANDBOX_PACKAGE}
#        GIT_REPOSITORY https://github.com/mozilla-services/lua_sandbox.git
#        GIT_TAG 97331863d3e05d25131b786e3e9199e805b9b4ba
        URL ${CMAKE_SOURCE_DIR}/externals/lua_sandbox
        SOURCE_DIR "${PROJECT_PATH}/src/github.com/mozilla-services/lua_sandboxt_clone_to_path"
        CMAKE_ARGS ${SANDBOX_ARGS}
        INSTALL_DIR ${PROJECT_PATH}
    )
endif()

if ("$ENV{GOPATH}" STREQUAL "")
   message(FATAL_ERROR "No GOPATH environment variable has been set. $ENV{GOPATH}")
endif()

add_custom_target(GoPackages ALL)

function(parse_url url)
    string(REGEX REPLACE ".*/" "" _name ${url})
    set(name ${_name} PARENT_SCOPE)

    # For details of the URI parsing see: http://tools.ietf.org/html/rfc3986#appendix-A
    string(REGEX REPLACE "^[a-zA-Z][-+.a-zA-Z0-9]+://" "" _path ${url}) # strip the scheme
    string(REGEX REPLACE "^[A-Za-z0-9$-._~!:;=]+@" "" _path ${_path}) # strip the userinfo
    string(REGEX REPLACE "^([^:/]+):[0-9]+/" "\\1/" _path ${_path}) # strip the port
    string(REGEX REPLACE "^([^:/]+):/?" "\\1/" _path ${_path}) # strip the colon separator and make sure we have a slash
    string(REGEX REPLACE "#.*$" "" _path ${_path}) # strip the revision

    set(path ${_path} PARENT_SCOPE)
endfunction(parse_url)

function(git_clone url tag)
    parse_url(${url})
    externalproject_add(
        ${name}
        GIT_REPOSITORY ${url}
        GIT_TAG ${tag}
        SOURCE_DIR "${PROJECT_PATH}/src/${path}"
        BUILD_COMMAND ""
        CONFIGURE_COMMAND ""
        INSTALL_COMMAND ""
        UPDATE_COMMAND "" # comment out to enable updates
    )
    add_dependencies(GoPackages ${name})
endfunction(git_clone)

function(git_clone_to_path url tag dest_path)
    parse_url(${url})
    externalproject_add(
        ${name}
        GIT_REPOSITORY ${url}
        GIT_TAG ${tag}
        SOURCE_DIR "${PROJECT_PATH}/src/${dest_path}"
        BUILD_COMMAND ""
        CONFIGURE_COMMAND ""
        INSTALL_COMMAND ""
        UPDATE_COMMAND "" # comment out to enable updates
    )
    add_dependencies(GoPackages ${name})
endfunction(git_clone_to_path)

function(hg_clone url tag)
    parse_url(${url})
    externalproject_add(
        ${name}
        HG_REPOSITORY ${url}
        HG_TAG ${tag}
        SOURCE_DIR "${PROJECT_PATH}/src/${path}"
        BUILD_COMMAND ""
        CONFIGURE_COMMAND ""
        INSTALL_COMMAND ""
        UPDATE_COMMAND "" # comment out to enable updates
    )
    add_dependencies(GoPackages ${name})
endfunction(hg_clone)

function(svn_clone url tag)
    parse_url(${url})
    externalproject_add(
        ${name}
        SVN_REPOSITORY ${url}
        SVN_REVISION ${tag}
        SOURCE_DIR "${PROJECT_PATH}/src/${path}"
        BUILD_COMMAND ""
        CONFIGURE_COMMAND ""
        INSTALL_COMMAND ""
        UPDATE_COMMAND "" # comment out to enable updates
    )
    add_dependencies(GoPackages ${name})
endfunction(svn_clone )

function(local_clone url)
    parse_url(${url})
    externalproject_add(
        ${name}
        URL ${CMAKE_SOURCE_DIR}/externals/${name}
        SOURCE_DIR "${PROJECT_PATH}/src/${path}"
        BUILD_COMMAND ""
        CONFIGURE_COMMAND ""
        INSTALL_COMMAND ""
        UPDATE_ALWAYS true
    )
    add_dependencies(GoPackages ${name})
endfunction(local_clone)

function(local_clone_to_path url dest_path)
    parse_url(${url})
    externalproject_add(
        ${name}
	URL ${CMAKE_SOURCE_DIR}/externals/${name}
        SOURCE_DIR "${PROJECT_PATH}/src/${dest_path}"
        BUILD_COMMAND ""
        CONFIGURE_COMMAND ""
        INSTALL_COMMAND ""
        UPDATE_ALWAYS true
    )
    add_dependencies(GoPackages ${name})
endfunction(local_clone_to_path)

function(add_external_plugin vcs url tag)
    parse_url(${url})
    if  ("${tag}" STREQUAL ":local")
       local_clone(${url})
    else()
        if ("${vcs}" STREQUAL "git")
           git_clone(${url} ${tag})
        elseif("${vcs}" STREQUAL "hg")
           hg_clone(${url} ${tag})
        elseif("${vcs}" STREQUAL "svn")
           svn_clone(${url} ${tag})
        else()
           message(FATAL_ERROR "Unknown version control system ${vcs}")
        endif()
    endif()

    set(ignore_root FALSE)
    foreach(_subpath ${ARGN})
        if ("${_subpath}" STREQUAL "__ignore_root")
            set(ignore_root TRUE)
        else()
            set(_packages ${_packages} "${path}/${_subpath}")
        endif()
    endforeach()

    if (NOT ${ignore_root})
        set(_packages ${path})
    endif()
    set(PLUGIN_LOADER ${PLUGIN_LOADER} ${_packages} PARENT_SCOPE)
endfunction(add_external_plugin)

execute_process(COMMAND "${GO_EXECUTABLE}" install "${CMAKE_SOURCE_DIR}/goyacc/yacc.go")

local_clone(https://github.com/rafrombrc/gomock)
add_custom_command(TARGET gomock POST_BUILD
COMMAND ${GO_EXECUTABLE} install github.com/rafrombrc/gomock/mockgen)
local_clone(https://github.com/rafrombrc/whisper-go)
local_clone(https://github.com/rafrombrc/go-notify)
local_clone(https://github.com/bbangert/toml)
local_clone(https://github.com/streadway/amqp)
local_clone(https://github.com/rafrombrc/gospec)
local_clone(https://github.com/crankycoder/xmlpath)
local_clone(https://github.com/thoj/go-ircevent)
local_clone(https://github.com/cactus/gostrftime)

local_clone(https://github.com/golang/snappy)
local_clone(https://github.com/eapache/go-resiliency)
local_clone(https://github.com/eapache/queue)
local_clone_to_path(https://github.com/rafrombrc/sarama github.com/Shopify/sarama)
local_clone(https://github.com/davecgh/go-spew)

add_dependencies(sarama snappy)

if (INCLUDE_GEOIP)
    add_external_plugin(git https://github.com/abh/geoip da130741c8ed2052f5f455d56e552f2e997e1ce9)
endif()

if (INCLUDE_DOCKER_PLUGINS)
    local_clone(https://github.com/fsouza/go-dockerclient)
endif()

if (INCLUDE_MOZSVC)
    #git_clone(https://github.com/bitly/go-simplejson ec501b3f691bcc79d97caf8fdf28bcf136efdab8)
    local_clone(https://github.com/AdRoll/goamz)
    local_clone(https://github.com/feyeleanor/raw)
    local_clone(https://github.com/feyeleanor/slices)
    add_dependencies(slices raw)
    local_clone(https://github.com/feyeleanor/sets)
    add_dependencies(sets slices)
    local_clone(https://github.com/crankycoder/g2s)
    add_external_plugin(git https://github.com/mozilla-services/heka-mozsvc-plugins :local)
    local_clone(https://github.com/getsentry/raven-go)
    add_dependencies(heka-mozsvc-plugins raven-go)
endif()

local_clone(https://github.com/pborman/uuid)
local_clone(https://github.com/gogo/protobuf)
add_custom_command(TARGET protobuf POST_BUILD
COMMAND ${GO_EXECUTABLE} install github.com/gogo/protobuf/protoc-gen-gogo)

include(plugin_loader OPTIONAL)

if (PLUGIN_LOADER)
    set(_PLUGIN_LOADER_OUTPUT "package main\n\nimport (")
    list(SORT PLUGIN_LOADER)
    foreach(PLUGIN IN ITEMS ${PLUGIN_LOADER})
        set(_PLUGIN_LOADER_OUTPUT "${_PLUGIN_LOADER_OUTPUT}\n\t _ \"${PLUGIN}\"")
    endforeach()
    set(_PLUGIN_LOADER_OUTPUT "${_PLUGIN_LOADER_OUTPUT}\n)\n")
    file(WRITE "${CMAKE_BINARY_DIR}/plugin_loader.go" ${_PLUGIN_LOADER_OUTPUT})
endif()
