> RDL > Class > Complex

<br/>

# Complex
`v1.0.0`

Complex is a datatype that represents a [complex number](https://en.wikipedia.org/wiki/Complex_number). It consists of a real and imaginary component. This class includes methods and overloads to make working with these numbers easier.

The numbers in this class are represented in rectangular form.

<br/><br/>
## Constructors

```c#
Complex.new (float x = 0.0, float y = 0.0)
```
Creates a complex number from real and imaginary components.

#
```c#
Complex.fromPolar (float phaseAngle, float magnitude)
```
Creates a complex number from polar form.
#

<br/><br/>
## Properties

```c#
float Complex.X
```
The real component of the complex number.

#
```c#
float Complex.Y
```
The imaginary component of the complex number.

#
<br/><br/>
## Methods
#

```c#
float Complex:Magnitude ()
```
Returns the magnitude/modulus/length/absolute value of the complex number.

#
```c#
float Complex:AbsSquare ()
```
Returns the square of the magnitude of the complex number.

#
```c#
Complex Complex:Conjugate ()
```
Returns the complex conjugate.

#
```c#
float, float Complex:ToPolar ()
```
Returns phase angle followed by the magnitude of the complex number.

#
```c#
int Complex:Orbit (Complex c, int maxIter, float escapeOrbit = 2.0)
```
Iterates a complex number through the function `z = z^2 + c` until it has escaped or has reached the max iteration count.
Returns the amount of iterations taken.
> `z`'s initial value is the instance this method was called on.
#

<br/><br/>
## Operations

```c#
Complex Complex + Complex
```
Returns the sum of two complex numbers.

#
```c#
Complex Complex - Complex
```
Returns the negation of two complex numbers.

#
```c#
Complex Complex * Complex
```
Returns the product of two complex numbers.

#
```c#
Complex Complex / Complex
```
Returns the quotient of two complex numbers.

#
```c#
Complex Complex ^ Complex
```
> *Note: This is many times slower than multiplication.*

> 0^0 is undefined.

Returns the value of a complex number raised to the power of another complex number.

