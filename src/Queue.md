> RDL > Class > Queue

<br/>

# Queue
`v1.0.0`

Queues are a type of datastructure, operates as FIFO, elements are pushed onto the end, popped from the front.
<br/><br/>

## Constructors

```c#
Queue.new<T> ()
```
Creates an empty queue.
#
```c#
Queue.new<T> (T...)
```
Creates a queue filled with given arguments.
#

<br/><br/>
## Methods

```c#
void Queue:Push<T> (T value)
```
Appends the value onto the end of the queue.
#

```c#
T Queue:Pop<T> ()
```
Removes and returns the value at the front of the queue.
#

```c#
T Queue:GetFirst<T> ()
```
Returns the value at the front of the queue.
#

```c#
T Queue:GetLast<T> ()
```
Returns the value at the end of the queue.
#

```c#
int Queue:Size<T> ()
```
Calculates and returns the number of elements in the queue.
#