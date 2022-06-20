> RDL > Class > Hitbox

# Hitbox

The hitbox class uses raycasting to create accurate hitboxes that work with any shape/speed using `Attachment` instances.
<br/><br/>

## Constructors

```c#
Hitbox.new (Model model, string? attachmentName)
```
Creates a hitbox given a model.<br/>
Will loop through all descendants of the model and reference every attachment wip
<br/><br/>  <br/>

## Properties

```c#
ScriptSignal Hitbox.Hit (RaycastResult result)
```
ScriptSignal that fires when the hitbox hits an object..
<br/><br/><br/>

```c#
RaycastParams? Hitbox.RaycastParams = nil
```
RaycastParams the hitbox uses.
<br/><br/><br/>

```c#
bool Hitbox.Debug
```
Enabled debug mode.
<br/><br/><br/>

## Methods

```c#
float Hitbox:Start ()
```
Starts raycasting on the next stepped event..
<br/><br/><br/>

```c#
float Hitbox:Stop ()
```
Stops raycasting immediately.

