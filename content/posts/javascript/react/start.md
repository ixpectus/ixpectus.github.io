---
title: "Быстрый старт в react"
date: 2021-09-17T22:40:13+03:00
tags:
  - react
  - javascript
summary: "Быстрый старт в react"
---
## Команды 
```javascript
npx create-react-app my-app
cd my-app/
npm start
```

## jsx
Корректное выражение 
```jsx
const b = <div id={name}>{<p>paragraph</p>}</div>;
```
## Что делать когда компоненту нужно отдавать несколько компонент без корневого элемента 
Например компонент должен вернуть что-то такое
```javasript
class Section extends React.Component {
  render() {
    const { header, body } = this.props;

    return (
      <div>
        <h2>{header}</h2>
        <div>{body}</div>
      </div>
    );
  }
}
```
Если `<div>` с точки зрения верстки не нужен, то можно переписать так
```javasript
class Section extends React.Component {
  render() {
    const { header, body } = this.props;

    return (
      <React.Fragment>
        <h2>{header}</h2>
        <div>{body}</div>
      </React.Fragment>
    );
  }
}
```
Короткая версия выглядит так
```javasript
class Section extends React.Component {
  render() {
    const { header, body } = this.props;

    return (
      <>
        <h2>{header}</h2>
        <div>{body}</div>
      </>
    );
  }
}
```
## Классы 
Для того, чтобы написать имя класса для div нужно его заменить на className, например
```javascript
<div className="super-class">content</div>

```

## Функциональные компоненты 
Если компонент реакт не должен содержать состояния то правильно использовать функциональные компоненты, пример
```
const FuncList = (props) => {
  return (
    <ul>
      {props.items.map((v) => (
        <li>{v}</li>
      ))}
    </ul>
  );
};
export default FuncList;
```

## Как вывести все вложенные элементы в компоненте
Для этого можно использовать свойство `children` из `this.props`
```javascript
  render() {
    const { children } = this.props;
    return <div className="alert alert-primary">{children}</div>;
  }
```
Пример использования
```javascript
    <div>
      <Alert2>
        <p>Paragraph 1</p>
        <hr />
        <p className="mb-0">Paragraph 2</p>
      </Alert2>
    </div>
```

## Иммутабельность 
В реакте всё построено на иммутабельности и могут возникнуть сложности при изменении одного из элементов

### Массивы 
- Добавление элемента в массив
    ```javascript
    const items = ['one', 'two', 'three'];
    const item = 'four';
    const newItems = [...items, item];
    // ['one', 'two', 'three', 'four'];
    ```
- Удаление элемента из массива
    ```javascript
    const newItems = items.filter((item) => item.id !== id);
    ```
- Изменение элемент в массиве
  - На чистом js
    ```javascript
      const index = items.findIndex((item) => item.id === id);
      const newItem = { ...items[index], value: 'another value' };
      const newItems = [...items.slice(0, index), newItem, ...items.slice(index + 1)];
    ```
  - С помощью immutability-helper
    ```javascript
      import update from 'immutability-helper';

      const collection = { children: ['zero', 'one', 'two'] };
      const index = 1;
      const newCollection = update(collection, { children: { [index]: { $set: 1 } } });
      // { children: ['zero', 1, 'two'] }
    ```

### Объекты
- Добавить элемент в объекте
  - Если ключ известен
    ```javascript
        const items = { a: 1, b: 2 };
        const newItems = { ...items, c: 3 };
        // { a: 1, b: 2, c: 3 }
    ```
  - Если ключ динамический
    ```javascript
        const items = { a: 1, b: 2 };
        const key = 'c';
        const newItems = { ...items, [key]: 3 };
        // { a: 1, b: 2, c: 3 }
    ```
- Удаление ключа в объекте
    ```javascript
    const { deletedKey, ...newState } = state;
    ```
- Глубокая вложенность
    ```javascript
    import update from 'immutability-helper';

    const myData = {
      x: { y: { z: 5 } },
      a: { b: [1, 2] },
    };

    const newData = update(myData, {
      x: { y: { z: { $set: 7 } } },
      a: { b: { $push: [9] } }
    });
    console.log(newData)
    // => { x: { y: { z: 7 } }, a: { b: [ 1, 2, 9 ] } }
    ```

### Жизненный цикл компонента 
#### Монитрование 
- constructor
- static getDerivedStateFromProps()
- render()
- componentDidMount()
#### Обновление
- static getDerivedStateFromProps()
- shouldComponentUpdate()
- render()
- getSnapshotBeforeUpdate()
- componentDidUpdate()
#### Удаление 
- componentWillUnmount()
#### Пример 
```javascript
class Clock extends React.Component {
  constructor(props) {
    super(props);
    this.state = { date: new Date() };
  }

  componentDidMount() {
    this.timerId = setInterval(() => this.setState({ date: new Date() }), 1000);
  }

  componentWillUnmount() {
    clearInterval(this.timerId);
  }

  render() {
    const { date } = this.state;
    return (
      <div>{date.toLocaleTimeString()}</div>
    );
  }
}
```

