---
title: "TCP протокол"
date: 2021-04-03T21:46:58+03:00
tags: 
  - linux 
  - network
  - tcp
summary: "Описание базовых особенностей протокола TCP"
---

### TCP
Протокол транспортного уровня
* TCP гарантирует доставку сообщения
* TCP заголовок
  ```
  Source Port | Destination Port
  -----------------------------
      Sequence number
  -----------------------------
      Acknowledgement number
  -----------------------------
  Flags (SYN, ACK, RST, FIN, PSH, URG, E(ECN Echo), W(ECN Cwnd Reduced))
  -----------------------------
          Checksum
  ```

#### Процесс TCP соединения
* TCP handshake
```
    me --> syn
              <--syn 
              <--ack
    me --> ack
```

 Т.е. сначала я отправляю пакет, у которого флаг syn установлен в 1. Другая сторона возвращает пакет, у которого установлено 2 флага syn и ack.
 Затем я отправляю пакет, у которого установлен флаг ack
##### Как увидеть процесс tcp handshake своими глазами
* Нужно начать слушать tcp соединение. Для этого в одной консоли нужно набрать`sudo tcpdump host jvns.ca`, 
* В другой консоли `curl jvns.ca`, и мы увидим
 ```
 09:55:56.520909 IP archlinux.58068 > 104.28.7.94.http: Flags [SEW], seq 1101291073, win 29200, options [mss 1460,sackOK,TS val 521376349 ecr 0,nop,wscale 7], length 0                                            
 09:55:56.523234 IP 104.28.7.94.http > archlinux.58068: Flags [S.E], seq 1641165503, ack 1101291074, win 29200, options [mss 1460,nop,nop,sackOK,nop,wscale 10], length 0                                          
 09:55:56.523259 IP archlinux.58068 > 104.28.7.94.http: Flags [.], ack 1, win 229, length 0
 ```
* `S` syn, `.`  ack
* E дополнительный флаг ECE "indicate that the TCP peer is ECN capable during 3-way handshake"
* W is CWR "Congestion Window Reduced (CWR) flag is set by the sending host to indicate that it received a TCP segment with the ECE flag set"
##### Разбивка сообщения на пакеты 
* У TCP есть буффер, в который пишутся данные, и когда буффер заполнен, они отправляются.
  * Если передать флаг Push, то произойдёт немедленная отправка
* Отправка пакетов происходит с некими уникальными идентификаторами
* Другая сторона говорит, какие пакеты получила
* Другая сторона должна собрать полученные пакеты в правильном порядке. Для этого используется понятие sequence number. 
  Допустим 
  ```
    "unce upon a" > bytes 0-13
    "agical master" > bytes 30-42
    "time there was a m" > bytes 13-30 
  ```
  Первое число, т.е. 0, 30, 13 и есть sequence number
* Для того, чтобы гарантировать доставку для каждого сообщения из пакета друга сторона должна ответить `ack`


#### Почитать
* [Про флаги tcp](http://packetlife.net/blog/2011/mar/2/tcp-flags-psh-and-urg/)
