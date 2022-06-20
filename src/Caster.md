> RDL > Class > Caster

<br/>

# Caster
`v1.0.0`

The caster class is a wrapper for the `cast` library to simplify the simulation of projectiles.

If max performance is needed it is recommended to use the `cast` library directly.

Important information:

1. This class sets the stepped callback of the `cast` library with `cast.bindToStepped` and connects it to a run service event; if this class is used you will not be able to use the `cast` library separately for your own purposes.
2. Casts created by `Caster::Fire()` are automatically assigned a table with structure `{Caster = Caster}`. You are free to assign your own fields to this table but if you change the caster field or the table itself, the resulting behaviour is undefined.
3. When terminating casts created with `Caster::Fire()`, the method `Caster::Terminate(id)` should be used instead of `cast.terminate(id)` to terminate casts, as `cast.terminate` will not invoke `Caster.Terminating`.

<br/><br/>

## Constructors

```c#
Caster.new ()
```
Creates a new caster instance.
#
<br/><br/>

## Properties

```c#
Vector3 Caster.Acceleration = Vector3.new(0, 0, 0)
```
The acceleration to automatically apply to all of this caster's projectiles.
#
```c#
RaycastParams? Caster.RaycastParams = RaycastParams.new()
```
RaycastParams the caster assigns to its casts by default.
> ⚠️ If you intend on modifying individual cast's raycast params, you must create a new copy for that cast. By default the RaycastParams instance here is the same instance referenced by new cast instances.
#
```c#
function Caster.CanPierce <(Cast id, RaycastResult hit) -> boolean>
```
Function to determine if the cast is able to pierce an object it hits.
Return true to pierce and continue the cast, return false to terminate the cast.
> This function should only be used to determine if the cast can pierce or not, changes to trajectory, etc, should be done in Caster.Pierced.
#
```c#
function Caster.Stepped <(Cast id, float dt)>
```
Called after each cast step.
#
```c#
function Caster.Pierced <(Cast id, RaycastResult hit)>
```
Called when the cast successfully pierces an object (determined by `Caster.CanPierce`).
#
```c#
function Caster.Hit <(Cast id, RaycastResult hit)>
```
Called when the caster hits an object and does not pierce. Cast will subsequently terminate.
> Cleanup of extra data should not be handled here, instead should be handled in Caster.Terminating in the event that the caster never hits anything.
#
```c#
function Caster.Terminating <(Cast id)>
```
Called when the cast is about to be terminated and have its data cleared. Data relevant to the cast is still safe to access in the scope of this function.
#

<br/><br/>

## Methods

```c#
Cast Caster:Fire (Vector3 origin, Vector3 velocity)
```
Creates a new cast instance with the given origin and velocity. Returns the id of the new cast instance.
> ⚠️ This id is only safe to use within the scope of the function that called this method. Do not save this id for later use.
#
```c#
RaycastParams Caster:CloneRaycastParams ()
```
Returns a copy of the caster's RaycastParams instance.
If no raycast parameters were assigned then this method returns the value returned by `RaycastParams.new()`.
#
```c#
RaycastParams Caster:Terminate (Cast id)
```
Terminates and cleans up a cast instance.
#

<br/><br/>

## Example Code
The example code below creates a caster that shoots projectiles that richochet infinitely.

```lua
-- require rdl
local rdl = require(RDL)

-- import types
type Caster = rdl.Caster
type Cast = rdl.Cast

-- import caster class and cast library
local Caster = rdl.Caster
local cast = rdl.cast

-- some instance to serve as a cosmetic projectile.
local ball: Instance = workspace.Ball

-- create the caster instance.
local caster: Caster = Caster.new()

-- define the fire function
local function fire(origin: Vector3, velocity: Vector3)
    -- fire caster and get the cast id
    local id: number = caster:Fire(origin, velocity)

    -- clone the ball and set its parent to workspace.
    local newball = ball:Clone()
    newball.Parent = workspace

    -- add reference to newball to the cast's extra data
    -- (extra data by default is a table with field "Caster" containing a
    -- reference to the caster instance that fired it)
    cast.getUserData(id).Cosmetic = newball
end

-- set caster properties
caster.Acceleration = Vector3.new(0, -9.81, 0)
caster.CanPierce = function(id: Cast, hit: RaycastResult)
    return true -- always pierces
end

function caster.Stepped(id: Cast, dt: number)
    -- visualize the cast for debugging purposes
    cast.visualize(id, dt, workspace)
    -- set position of ball to the cast's current position
    cast.getUserData(id).Cosmetic.Position = cast.getPosition(id)
end

-- using the pierced callback to ricochet the projectile
function caster.Pierced(id: Cast, hit: RaycastResult)
    -- reposition the cast to the point of impact 
    -- (cast will have travelled slightly passed the point of impact
    -- in a single simulation step)
    -- and add a fraction of the normal
    -- (to help ensure raycast does not begin in the reflected object
    -- as raycasts will ignore the object they begin in)
    cast.setPosition(id, hit.Position + hit.Normal*0.01)
    -- ricochet the cast based on the hit normal vector
    cast.reflect(id, hit.Normal)
end

-- this function will never actually run since cast will always pierce
function caster.Hit(id: Cast, hit: RaycastResult)

end

-- this function will also never actually run since the cast always pierces
-- should the code be changed so that the cast can fail to pierce, this function
-- will clean up the cast's cosmetic projectile.
function caster.Terminating(id: Cast)
    cast.getExtraData(id).Cosmetic:Destroy()
end
```

