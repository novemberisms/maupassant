-- feel free to change this to your own copies of these libraries in your own project

local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local PATH_TO_CLASSIC_GETSET = _PACKAGE .. "/dependencies/classic_getset"
local PATH_TO_OMNIMATE = _PACKAGE .. "/dependencies/omnimate_v_3_27"
local PATH_TO_BRINEVECTOR = _PACKAGE .. "/dependencies/brinevector"

local dep = {}

dep.Object = require(PATH_TO_CLASSIC_GETSET)
dep.omnim8 = require(PATH_TO_OMNIMATE)
dep.Vector = require(PATH_TO_BRINEVECTOR)

return dep