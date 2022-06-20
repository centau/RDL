--------------------------------------------------------------------------------
-- RDL.lua
-- @version 1.0.0
--------------------------------------------------------------------------------

--[[
    Roblox Development Library
    Provides commonly used classes, datastructures, libraries and functions to assist in development.
    This library and all its components are licensed under the MIT license.
]]

local _t = require(script._typedefs)

export type Complex = _t.Complex
export type ScriptSignal<T...> = _t.ScriptSignal<T...>
export type ScriptConnection = _t.ScriptConnection
export type Hitbox = _t.Hitbox
export type Caster = _t.Caster
export type Cast = _t.Cast
export type Fabrik = _t.Fabrik
export type IKConstraint = _t.IKConstraint

local rdl = {}

rdl.Complex = require(script.Complex)
rdl.Queue = require(script.Queue)
rdl.memoize = require(script.memoize)
rdl.enum = require(script.enum)
rdl.ScriptSignal = require(script.ScriptSignal)
rdl.Hitbox = require(script.Hitbox)
rdl.cast = require(script.cast)
rdl.Caster = require(script.Caster)
rdl.Fabrik = require(script.Fabrik)
rdl.quick = require(script.quick)

return rdl
