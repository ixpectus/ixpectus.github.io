---
title: "Применение функций в haskell"
date: 2021-05-03T12:37:49+03:00
tags:
  - haskell 
summary: "Как работать с функциями в haskell"
---
## Как определять функции 
- Определение функции с двумя аргументами `x` и `y`
  ```haskell
  sumSquares x y = x ^ 2 + y ^ 2
  ```
- Определение функции без аргументов
  ```haskell
  three = 3
  ```
## Как применять функции 
- Применение функции идёт без дополнительных скобок, в префиксном стиле, сначала пишется функция, а потом через пробел её аргументы
  ```haskell
  Prelude> sumSquares 2 3
  13
  ```
- В аргументе функции может быть другая функция, например `three`, описанная выше
  ```haskell
  Prelude> sumSquares 2 three
  13
  ```
- Если функция в аргументе ожидает других аргументов, то их нужно окружить скобками
  ```haskell
  Prelude>  sumSquares 2 (sumSquares 2 3)
  173
  ```

## Частичное применение функций
Любую функцию в haskell можно применить частично(вообще любую). Частично значит, что для функции n аргументов можно задать один аргумент и мы получим функцию n-1 аргументов
- Пример частичного применения на haskell
  ```haskell
  Prelude> sumSquares x y = x ^ 2 + y ^ 2
  Prelude> sumSquares3 = sumSquares 3
  Prelude> sumSquares3 1
  10
  ```
- Как такая же логика выглядела бы на go
  ```go
  package main

  import "fmt"

  func main() {
    sumSquares3 := sumSquaresPart(3)
    fmt.Println(sumSquares3(1))
  }

  func sumSquaresPart(x int) func(y int) int {
    return func(y int) int {
      return x*x + y*y
    }
  }
  ```

В haskell не нужно делать ничего дополнительного для того, чтобы функцию можно было применять частично

## Условные операторы
В отличие от императивных операторов у условных операторов в haskell всегда должно быть заполнено условие then
```haskell
if x > 0 then 1 else (-1)
```


