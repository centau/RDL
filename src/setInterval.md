> RDL > Function > setInterval

# setInterval

This function serves as a better alternative to the common `while wait() do` pattern.

It uses a self-correcting and non-yielding method to stay acccurate over long periods of time and to relieve stress off the task scheduler.
<br/><br/>

```c#
RBXScriptConnection setInterval (float interval, function callback)
```
Connects and runs a given callback at a specified interval.

Returns a RBXScriptConnection you can disconnect to stop the callback.