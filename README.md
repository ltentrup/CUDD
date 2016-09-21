# CUDD

A swifty (and incomplete) wrapper around the [CUDD](http://vlsi.colorado.edu/~fabio/) ROBDD library by Fabio Somenzi.

## Example

```swift
import CUDD

let manager = CUDDManager()
let a = manager.newVar()
let b = manager.newVar()
let function = a & b
assert(function.ExistAbstract(cube: a & b) == manager.one(), "∃ a, b. (a & b) == true")
assert(function.UnivAbstract(cube: a) == manager.zero(), "∀ a. (a & b) == false")
```


# Installation

## Swift Package Manager

```swift
.Package(url: "https://github.com/ltentrup/CUDD.git", majorVersion: 0, minor: 2)
```
