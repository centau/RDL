> RDL > Library > cast

<br/>

# cast
`v1.0.0`

Data oriented designed raycast projectile simulation library.

By default, benchmarked to simulate a single step for 10,000 cast instances in 0.01 seconds (total of 1,000,000 individual steps in 1 second). 

10,000 cast instances without custom raycast parameters or extra data take up 512 kb of memory, approximitely 51 bytes per cast instance.
<br/><br/>

## Independant Functions
Functions not associated with a specific cast instance.

#
```c#
void cast.simulate (float dt)
```
Advances simulation of all projectiles by specified timestep `dt`.
#
```c#
Cast cast.create (Vector3 position, Vector3 velocity, RaycastParams rayparams, any extraData = nil)
```
Creates a new cast with the given arguments. Returns the id of the new cast instance.
>⚠️ The ID returned here should only be used within the function scope that `cast.create` was called in and should not be cached at all. Cast instances may be assigned a new ID after the next simulation step.
#
```c#
void cast.bindToStepped (function callback) <Cast id, RaycastResult? result>
```
Sets the function to be ran after each cast step.
> Does not take effect until the next simulation step cycle.

>⚠️ Functions bound must not yield!
#
```c#
int cast.getCount ()
```
Returns amount of casts currently being simulated.
#
```c#
void cast.terminateAll ()
```
Terminates all casts.
>⚠️ Function is automatically deferred to the end of the current resumption cycle to avoid breaking the current simulation step.

<br/><br/>

## Dependant Functions
Functions associated with a specific cast instance.

#
```c#
void cast.terminate (Cast id)
```
Stops and cleans up the cast instance.
#
```c#
Vector3 cast.getPosition (Cast id)
```
Returns the position of the cast.
#
```c#
void cast.setPosition (Cast id, Vector3 position)
```
Sets the position of the cast.
#
```c#
Vector3 cast.getVelocity (Cast id)
```
Returns the velocity of the cast.
#
```c#
void cast.setVelocity (Cast id, Vector3 velocity)
```
Sets the velocity of the cast.
#
```c#
void cast.addVelocity (Cast id, Vector3 velocity)
```
Adds the given velocity onto the casts current velocity.
#
```c#
RaycastParams cast.getRaycastParams (Cast id)
```
Returns the RaycastParams instance of the cast.
#
```c#
void cast.setRaycastParams (Cast id, RaycastParams raycastParams)
```
Sets the RaycastParams instance of the cast.
#
```c#
any cast.getUserData (Cast id)
```
Returns any user-defined data assigned to the cast.
User data is `nil` by default.
#
```c#
void cast.setUserData (Cast id, any value)
```
Assigns any user-defined data to the cast. This can be set to a table to store any amount of data for each cast instance.
#
```c#
Vector3 cast.reflect (Cast id, Vector3 normal)
```
Sets the cast's velocity to a reflected vector with the same magnitude based on the normal argument and returns the new velocity.
> The normal must be a normalized vector.g
#
```c#
void cast.visualize (Cast id, float dt, Instance parent)
```
Creates and parents a part to visualize the trajectory of the cast for a single step.
> ⚠️ This is intended for debugging purposes, not recommended for use in production.