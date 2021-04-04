---
title: "Процесс загрузки котика из интернета в очень общих словах"
date: 2021-04-04T22:17:24+03:00
tags: 
  - linux 
  - architecture
  - network
summary: "Что реально происходит, когда мы загружаем контент в интернете"
---
* По имени сайта получаем ip
  ```
  curl jvns.ca 
  trace -f  curl jvns.ca 4 -v 2>&1 | grep getaddrinfo
  getaddrinfo //находит dns server
  getaddrinfo //запрашивает у dns сервера ip адрес
  ```
  Обычно dns сервер лежит в /etc/resolv.conf
* Идёт обращение по ip, обращение идёт через множество маршрутизаторов, их количество можно увидеть `traceroute google.com`. Для того, чтобы роутеры могли друг друга находить используется протокол bgp
* Общение происходит с помощью сокетов ОС
  * ip адрес есть, нужно открыть сокет
    * Приложение обращается к ОС за сокетом
    * Сокет соединяется с ip адресом и портом 
    * В сокет идёт запись данных
  * Виды сокетов 
    * tcp
    * udp
    * raw
    * unix  для общения процессов
* Инициация общения по TCP
  ```
      me --> syn
              <--syn 
              <--ack
      me --> ack
  ```
* Запись данных в сокет
  ОС разбивает данные на кучу маленьких пакетов и шлёт их поочередно
    
