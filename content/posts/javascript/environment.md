---
title: "Настройка окружения для javascript разработки"
date: 2021-10-18T10:17:50+03:00                  
summary: "Набор полезных команд для настройки окружения"
tags:
  - environment 
  - javascript 
---

## Подготовка 
- Нужно установить node.js  
- Нужно остановить npm  
Для каждой операционной системы набор команд для установки может отличаться

## Создание проекта
- Инициализация
  ```javascript
  npm init
  ```
- После инициализации будет создан `package.json`
- Пример `package.json` при старте проекта
  ```
  {
    "name": "testproject",
    "version": "1.0.0",
    "description": "",
    "main": "index.js",
    "scripts": {
      "test": "jest --colors"
    },
    "author": "",
    "license": "ISC",
  }
  ```
- Нужно установить `type:"module"` в package.json. Без этого не удавалось подключать зависимости

## Запуск hello world 
- Все команды нужно запускать в корне созданного проекта
- `touch index.js` создаем файл, который будет запускаться
- `echo 'console.log("hello world")' > index.js` записываем в этот файл команду для вывода "hello world"
- `node index.js` в консоли мы должны увидеть "hello world"

## Установка зависимостей 
- `npm install lodash` пример установки крутого пакета `lodash`
- Примерно так будет выглядеть package.json после установки, т.е. `lodash` появился в `dependencies`
  ```
    {
      "type": "module",
      "name": "testproject",
      "version": "1.0.0",
      "description": "",
      "main": "index.js",
      "scripts": {
        "test": "jest --colors"
      },
      "author": "",
      "license": "ISC",
      "dependencies": {
        "lodash": "^4.17.21"
      }
    }
  ```
- Сам пакет `lodash` скачался и теперь лежит в нашем проекте `node_modules/lodash`
- `npm install --save-dev jest` пример установки пакета только для окружения разработчика
- Пакет добавится в поле `devDependencies` в `package.json`
  ```
  "devDependencies": {
    "jest": "^27.3.0"
  }
  ```

## Установка пакетов глобально 
- `npm install -g sloc` пример установки пакета глобально 
- `npm config ls -l | grep prefix` так можно посмотреть куда устанавливаются пакеты глобально 

## Для чего нужен npx 
- Бывает нужно установить зависимость для исполняемого файла не локально, а глобально. К примеру `prettier`, который форматирует код может быть установлен как локально так и глобально
- Если `prettier` будет установлен локально, то исполняемый файл будет лежать в `bin` и запускать его будет неудобно - `./node_modules/.bin/prettier`
- Для того,  чтобы запускать было удобно придумали `npx`, `npx prettier` будет эквивалентен `./node_modules/.bin/prettier`

## Настройка линтера 
- В мире javascript победил `eslint`
- `npm install --save-dev eslint` установка
- `npx eslint --init` настройка
- `npx eslint .` запуск линтера
- `npx eslint --fix .` запуск линтера сразу с исправлением ошибок, которые возможно исправить

