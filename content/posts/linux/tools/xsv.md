---
title: "Xsv ещё одна мощная cli утилита на rust"
date: 2021-12-18T22:25:15+03:00
tags:
  - linux 
  - cli
summary: "xsv позволяет в консоли эффективно работать с csv"
---
### xsv 
[https://github.com/BurntSushi/xsv/](https://github.com/BurntSushi/xsv/)

#### Флаги
- `-d` можно задать разделитель для csv файла, например `xsv -d ";"`
- `-n` не показывать заголовки

#### Примеры
- `xsv headers ./file.csv` выводит заголовки csv файла
  ```
    1   Country
    2   City
    3   AccentCity
    4   Region
    5   Population
    6   Latitude
    7   Longitude
  ```
- `xsv partition column1 tmp1 ./file.csv` строит партиции на основе колонки `column1` из файла
  - Данные по каждой партиции будут в отдельном фале в директории `tmp1`
- `xsv sample 10` отдаёт 10 случайных записей из файла
- `xsv table` превращает csv в удобную таблицу с табами
- `xsv index ./file.csv` стоит индекс на базе файла в той же директории
- `xsv split ./splits2 -s1000 ./file.csv` делит файл на много файликов размером 1000 строк и складывает их в директорию `splits2`
- `xsv split -h` показывает help по конкретной команде `split`, работает для всех команд
- `xsv select City,Latitude,Longitude worldcitiespop.csv` выводит конкретные поля из файла
- `xsv select City,Latitude,Longitude worldcitiespop.csv | xsv sample 10 | xsv table` выводит 10 случайных записей с разделителями табами
  ```
  City           Latitude    Longitude
  shar           34.479722   67.328334
  qol-e qobi     34.546692   68.199249
  petralonon     39.0111111  21.8175
  caserio salar  38.014705   -1.055148
  zhongshi       31.931917   121.531692
  bungo          11.566389   122.820278
  veyleh-ye do   34.3786     46.3589
  nizami banda   32.458333   71.173889
  gangra         31.101      98.101
  birecik        37.029444   37.990278
  ```



