---
title: "Типы в go"
date: 2022-07-25T10:29:15+03:00
tags:
  - go 
summary: "Типы в go. Краткий обзор"
---

## Встроенные типы 

### Базовые типы
- int, uint, int8, uint8(byte), int32(rune), uint32, int64, uint64
- float32, float64
- complex64, complex128
- string
- bool

### Составные типы
- указатели
- структуры
- функции
- интерфейсы 
- массивы
- слайсы
- мапы
- каналы
- интерфейсы

## Underlying types 
Низкоуровневые типы, которые лежат в основе 

## Указатели 
- нулевое значение - nil
- значение указателя хранит адрес в памяти другого значения
- адрес в памяти хранится в виде uintptr(unsigned int), 4 байта для 32 битной архитектуры, 8 байт для 64 битной
- `*int` пример обозначения указателя, int - базовый тип, указатель хранит адрес, по которому расположено значения типа int
- как инициировать указатель
  - `new(T)` выделяет память под значение типа T, значение инициируется своим нулевым значением
  - `&t` получает адрес существующего значения t
- как получить значение на которое ссылается указатель `*p`
  ```go
    t := 33 
    p := &t
    fmt.Printf("%v",*p) // 33
  ```
## Функции
- Объекты первого типа, могут передаваться в другие функции и возвращаться из них, как любые другие типы
- Нулевое значение - nil

## Строки 
### Внутреннее представление 
[Исходники](https://github.com/golang/go/blob/release-branch.go1.17/src/runtime/string.go#L229)
```go
type stringStruct struct {
	str unsafe.Pointer
	len int
}
```

## Интерфейс 
### Внутренне представление 
[Исходники](https://github.com/golang/go/blob/release-branch.go1.17/src/runtime/type.go#L366)
```go
type interfacetype struct {
	typ     _type
	pkgpath name
	mhdr    []imethod
}
```
### Мысли об интерфейсе 
- Интерфейсы в go неявные, то есть не нужно писать `A implemetes someInterface`
- Интерфейс можно рассмотреть, как некоторую сущность, которая хранит в себе набор методов и структуру, которые реализует эти методы
  - Похоже на некоторый адаптер
  - Конкретные значения упаковываются в интерфейс
  - При вызове метода интерфейса происходит вызов структуры, которую интерфейс запаковал

## Мапы 
### Внутренне представление 
[Исходники](https://github.com/golang/go/blob/release-branch.go1.17/src/runtime/type.go#L372)
```go
type maptype struct {
	typ    _type
	key    *_type
	elem   *_type
	bucket *_type // internal type representing a hash bucket
	// function for hashing keys (ptr to key, seed) -> hash
	hasher     func(unsafe.Pointer, uintptr) uintptr
	keysize    uint8  // size of key slot
	elemsize   uint8  // size of elem slot
	bucketsize uint16 // size of bucket
	flags      uint32
}
```

## Каналы 
### Внутреннеe представление 
[Исходники](https://github.com/golang/go/blob/release-branch.go1.17/src/runtime/type.go#L410)
```go
type chantype struct {
	typ  _type
	elem *_type
	dir  uintptr
}
```

## Слайсы
### Внутреннеe представление 
[Исходники](https://github.com/golang/go/blob/release-branch.go1.17/src/runtime/slice.go#L13)
```go
type slice struct {
	array unsafe.Pointer
	len   int
	cap   int
}
```

## Массивы
### Внутреннеe представление 
[Исходники](https://github.com/golang/go/blob/release-branch.go1.17/src/runtime/type.go#L403)
```go
type arraytype struct {
	typ   _type
	elem  *_type
	slice *_type
	len   uintptr
}
```

## Каналы
### Внутреннеe представление 
[Исходники](https://github.com/golang/go/blob/release-branch.go1.17/src/runtime/chan.go#L32)
```go
type hchan struct {
	qcount   uint           // total data in the queue
	dataqsiz uint           // size of the circular queue
	buf      unsafe.Pointer // points to an array of dataqsiz elements
	elemsize uint16
	closed   uint32
	elemtype *_type // element type
	sendx    uint   // send index
	recvx    uint   // receive index
	recvq    waitq  // list of recv waiters
	sendq    waitq  // list of send waiters

	// lock protects all fields in hchan, as well as several
	// fields in sudogs blocked on this channel.
	//
	// Do not change another G's status while holding this lock
	// (in particular, do not ready a G), as this can deadlock
	// with stack shrinking.
	lock mutex
}
```


## Ссылки 
- [Исходники go, можно найти внутреннее представление многих типов](https://github.com/golang/go/blob/release-branch.go1.17/src/runtime/type.go#L631)
