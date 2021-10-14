---
title: "Функции в javascript"
date: 2021-10-04T08:23:52+03:00
---

## Упаковка аргументов 
Можно передать любое количество аргументов с помощью `...` 
```javascript
const sum = (...numbers) => {
  let result = 0;
  for (let num of numbers) {
    result += num;
  }
  return result;
};
```
Также можно и сделать распаковку аргументов
```javascript
const numbers = [1, 7, 4];
sum(...numbers); // 12
```
Это эквивалентно
```javascript
sum(numbers[0], numbers[1], numbers[2]);
```

## Сокращенное объявление анонимных функций 
```javascript
const sum = (a, b) => a + b;
```

Эта запись эквивалентна
```javascript
const sum = function(a, b) {a + b};
```

## Деструктуризация массивов и объектов 
В javascript есть конструкция для деструктуризации массива или объекта. Деструктуризация по сути это разложение массива или объекта на переменные
### Пример деструктуризации массива
```javascript
const arr2 = [3, 10, 30];
const [var1, var2] = arr2;
console.log(var2); // выведет 3
```
### Пример деструктуризации объекта
```javascript
const obj = {
  prop1: "hiii",
  prop3: 33,
};
const { prop1 } = obj; // выведет hiii
console.log(prop1);
```

## Деструктуризация в аргументах функций 
Деструктуризацию можно провести прямо в объявлении функции. Это довольно интересная особенность, которую можно использовать для уменьшения связности.
К пример функция принимает объект из 10 элементов и явно в своем определении говорит, какие именно из полей будет использовать.
## Пример для объекта
```javascript
const obj = {
  prop1: "hiii",
  prop3: 33,
};
const acceptFullObject = (obj) => console.log(obj);
const acceptDestructuredObject = ({ prop3 }) => console.log(prop3);
acceptFullObject(obj); // выведет { prop1: 'hiii', prop3: 33 }
acceptDestructuredObject(obj); // выведет 33
```
## Пример для массива
```javascript
const arr = [1, 2, 3];
const acceptFullArr = (arr) => console.log(arr);
const acceptDestructuredArr = ([var1]) => console.log(var1);
acceptFullArr(arr);// выведет [1, 2, 3]
acceptDestructuredArr(arr); // выведет 1
```

## filter, sort, map 
### Пример использования filter и sort
```
const users = [
  { name: "Tirion", birthday: "Nov 19, 1988" },
  { name: "Sam", birthday: "Nov 22, 1999" },
  { name: "Rob", birthday: "Jan 11, 1975" },
  { name: "Sansa", birthday: "Mar 20, 2001" },
  { name: "Tisha", birthday: "Feb 27, 1992" },
  { name: "Chris", birthday: "Dec 25, 1995" },
];

const takeOldest = (items, num) => {
  if (num == undefined) {
    num = 1;
  }
  const res = items
    .sort(function (a, b) {
      const date1 = Date.parse(a.birthday);
      const date2 = Date.parse(b.birthday);
      return date1 > date2 ? 1 : -1;
    })
    .filter((item, i) => i < num);
  return res;
};
console.log(takeOldest(users));
```

### Пример использования map 
```
const items = [3, 4, 5, 7];
const res = items.map((item) => item * 2);
console.log(res);// [ 6, 8, 10, 14 ]
```

### Пример использования reduce
```
function groupBy(arr, fieldName) {
  return arr.reduce((acc, item) => {
    console.log(item);
    if (acc[item[fieldName]] == undefined) {
      acc[item[fieldName]] = [];
      acc[item[fieldName]].push(item);
    } else {
      acc[item[fieldName]].push(item);
    }
    return acc;
  }, {});
}
```
