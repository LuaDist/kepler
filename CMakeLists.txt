# Copyright (C) 2007-2012 LuaDist.
# Created by Peter Drahoš
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( kepler NONE )
cmake_minimum_required ( VERSION 2.8 )
include ( cmake/dist.cmake )
include ( lua )

# Install Kepler App files
install_lua_executable ( setup-kepler src/setup-kepler )
install_lua_executable ( cgilua.cgi src/cgilua.cgi )
install_lua_executable ( cgilua.fcgi src/cgilua.fcgi )
install_lua_executable ( op.cgi src/op.cgi )
install_lua_executable ( op.fcgi src/op.fcgi )
install_lua_executable ( xavante_start src/xavante_start )
install_data ( web css conf )
install_doc ( doc )
install_lua_module ( kepler_init src/kepler_init.lua )