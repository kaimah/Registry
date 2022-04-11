"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[748],{6905:function(e){e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Creates a new registry. Please note that the `initial` table may be any table so long as it has numeric or string keys.\\nIf `immutable` is set to true, you will not be able to modify the registry.","params":[{"name":"name","desc":"","lua_type":"string"},{"name":"initial","desc":"","lua_type":"table"},{"name":"immutable","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"Registry"}],"function_type":"static","source":{"line":333,"path":"src/init.lua"}},{"name":"get","desc":"Returns a registry given its name.","params":[{"name":"name","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Registry?"}],"function_type":"static","source":{"line":362,"path":"src/init.lua"}},{"name":"buildVirtualRegistry","desc":"Builds a registry from an instance and its children. If `recursive` is set to true, it will include all of its descendants.","params":[{"name":"name","desc":"","lua_type":"string"},{"name":"instance","desc":"","lua_type":"Instance"},{"name":"recursive","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"Registry"}],"function_type":"static","source":{"line":377,"path":"src/init.lua"}}],"properties":[],"types":[],"name":"RegistryModule","desc":"The entry point for the registry system.","source":{"line":11,"path":"src/init.lua"}}')}}]);