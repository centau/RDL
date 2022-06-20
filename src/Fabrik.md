> RDL > Classes > Fabrik

<br/>

# Fabrik
`v0.0.0 - This class is a WIP, members and functionality are subject to change.`

The Fabrik class encapsulates joints and segments for IK solving using the [FABRIK](http://andreasaristidou.com/FABRIK.html) algorithm.

<br/><br/>
## Constructors

```c#
Fabrik.new ()
```
Creates a new empty Fabrik instance.
#

<br/><br/>
## Properties

```c#
Array<Vector3> Fabrik.JointPositions
```
The array used to store the current positions of each joint.
#

```c#
Array<float> Fabrik.SegmentLengths
```
The array used to store the lengths of each segment.
#

```c#
Array<IKConstraint> Fabrik.JointConstraints
```
The array used to store IKConstraints, if any, defined for each joint.
#

<br/><br/>
## Methods

```c#
void Fabrik:AddSegment (float length, IKConstraint constraints = nil)
```
Appends a new segment with the given length onto the end of the current system and
applying optional constraints to the new joint.
#

```c#
bool Fabrik:Solve (Vector3 origin, Vector3 target)
```
Updates joint positions so that they will attempt span between origin and target, taking into account their current positions.
Returns a boolean indicating whether the target was reached within tolerances.
> This function will **not** take into account constraints.
#

```c#
bool Fabrik:ConstrainedSolve (CFrame origin, Vector3 target)
```
Same purpose as Fabrik:Solve except any constraints defined will be taken into account.
The `origin` parameter is now also a `CFrame`, used to apply constraints for the first joint.
Returns boolean indicating if the target was reached within tolerances.
#

```c#
void Fabrik:Reset ()
```
Sets the positions of each joint to Vector3.zero so that new solves will be done from scratch.
Useful for if a solve ends up stuck in an unwanted state.
#

```c#
Array<Vector3> Fabrik:GetJointPositions ()
```
Returns an array of the current joint positions in world coordinates of the system.
#

```c#
Array<CFrame> Fabrik:GetJointCFrames ()
```
Returns an array of CFrames in world coordinates for each, joint formed by the posistion of each joint facing in the direction of the next joint.
#

```c#
Array<CFrame> Fabrik:GetSegmentCFrames ()
```
Returns an array of CFrames in world coordinates for each segment, formed by the position of halfway between each joint and the next, in the direction of the next joint.

i.e. The CFrame of each segment if they were Part instances.
#

```c#
Array<CFrame> Fabrik:GetJointRelativeCFrames ()
```
Returns an array of CFrames for each joint, where each consecutive CFrame is described in local space relative to the previous joint CFrame.
Useful for when you have some rig made of Motor6Ds, and changing the offset of the motor topmost of the hierarchy will affect
the CFrames of every part down the rig hierarchy.
#

<br/><br/>

# IKConstraint

The IKConstraint is a typedef for `Array<float>` that describes the constraints a joint is bound by.

The array must have 4 entries, with each entry denoting a specific direction:
1. LEFT
2. UP
3. DOWN
4. RIGHT

Each entry is an angle in radians that must be within the range [-π, π].

The constraint is applied in local space to the CFrame formed by position P1, facing in the direction of P0 to P1, and up vector (0, 1, 0).

The angle describes the region the arm P1-P2 is constrained within, relative to the aforementioned CFrame.

Below is an example in two dimensions with `constraint = {0, math.pi/4, math.pi/2, 0}`.

<br/>

![image](https://user-images.githubusercontent.com/83140718/169670222-afe9a738-cf14-4572-a022-e14663dad721.png)
#

<br/><br/>

# Sample Code

```lua
local rdl = require(RDL)

local ik: rdl.Fabrik = rdl.Fabrik.new()

-- restrict movement to a 45 degree cone
local constraint: rdl.IKConstraint = {
    math.pi/4,
    math.pi/4,
    math.pi/4,
    math.pi/4
}

local N = 5
local LENGTH = 4

local parts: Array<Part> = table.create(N, nil)

for i = 1, N do
    ik:AddSegment(LENGTH, constraint)

    local p: Part = Instance.new("Part", workspace)
    p.Size = Vector3.new(0.5, 0.5, LENGTH)
    p.Anchored = true
    parts[i] = p
end

local start: CFrame = CFrame.new(0, 0, 0)
local target: Vector3 = Vector3.new(1, 4, 5)

ik:ConstrainedSolve(start, target)

for i: number, v: CFrame in ik:GetSegmentCFrames() do
    parts[i].CFrame = v
end
```