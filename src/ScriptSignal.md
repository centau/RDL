> RDL > Class > RDLScriptSignal

# RDLScriptSignal

RDLScriptSignal is an implementation of RBXScriptSignals created in pure luau.

There are a few key differences to note:
- Tables passed are passed by reference, not copied.
- Event handling is not deferred.
- Signal and connection objects do not have a Destroy method (they can be gced).
- Connection instances do not have a `RDLScriptConnection.Connected` property (instead use `RDLScriptConnect:IsConnected()`).

<br/><br/>
## Constructors

```c#
RDLScriptSignal.new<T...> ()
```
Creates a Signal instance.
#

<br/><br/>
## Methods

```c#
RDLScriptConnection RDLScriptSignal:Connect<T...> (function<T...> callback)
```
Connects a callback to be ran when fired.
Returns a connection instance used to handle the connection.
#

```c#
T... RDLScriptSignal:Wait<T...> ()
```
Yields the running coroutine until the signal is next fired.
#

```c#
void RDLScriptSignal:Fire<T...> (T... args)
```
Run all connected callbacks, passing the arguments given here.
#

```c#
void RDLScriptSignal:DisconnectAll ()
```
Disconnects all connections.
> *Note: this will not interrupt the current firing cycle.*
#

<br/><br/><br/>
# RDLScriptConnection

Connection instances represent callbacks connected to the signal.
They are used to determine the status of the connection and to disconnect the callback.

<br/><br/>
## Methods

```c#
bool RDLScriptConnection:IsConnected ()
```
Returns a boolean representing if the connection is still connected or not.
#

```c#
void RDLScriptConnection:Disconnect ()
```
Disconnects the callback so future firing will not run it.
#