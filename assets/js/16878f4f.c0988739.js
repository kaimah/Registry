"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[476],{12157:function(e){e.exports=JSON.parse('{"functions":[{"name":"lookup","desc":"Paths directly to the index in the registry. and returns the first value it finds. If you include `any` in part of the path,\\nthe search will begin to look through all descendants from that point. Therefore, it is only recommended  to use `any` as\\nthe second-to-last part of the path.\\n\\n```lua\\nlocal items = Registry.new(\\"Items\\", {\\n    melee = {\\n        axes = {\\n            stoneAxe = { quantity = 1 }\\n        },\\n\\n        swords = {\\n            stoneSword = { quantity = 1 }\\n        }\\n    }\\n})\\n\\n-- will return the stoneAxe data, but stoneSword was also considered in the search process due to the `any` tag.\\nlocal stoneAxeData = items:lookup(\\"melee/any/stoneAxe\\")\\n```","params":[{"name":"path","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"any?"}],"function_type":"static","source":{"line":434,"path":"src/init.lua"}},{"name":"search","desc":"Begins a SearchResult chain which you can use for more advanced indexing. See the SearchResult class for more information on what to do\\nwith this class.","params":[{"name":"path","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"SearchResult"}],"function_type":"static","source":{"line":491,"path":"src/init.lua"}},{"name":"set","desc":"In the directory of the specified path, set `key` equal to `value` so long as the registry is mutable.","params":[{"name":"path","desc":"","lua_type":"string"},{"name":"key","desc":"","lua_type":"string | number"},{"name":"value","desc":"","lua_type":"any"}],"returns":[],"function_type":"static","source":{"line":511,"path":"src/init.lua"}}],"properties":[{"name":"name","desc":"","lua_type":"string","source":{"line":23,"path":"src/init.lua"}}],"types":[],"name":"Registry","desc":"A registry created from a table, with a variety of indexing and search functions.","source":{"line":21,"path":"src/init.lua"}}')}}]);