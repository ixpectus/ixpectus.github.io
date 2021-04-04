---
title: "DNS"
date: 2021-04-03T21:25:04+03:00
tags: 
  - linux 
  - network
  - dns
summary: "Какие бывают dns сервера и как понять с каким dns сервером идёт работа"
---
### DNS сервер
По имени хоста(например yandex.ru) отдаёт ip адрес, по которому можно обратиться и получить данные

#### Типы dns серверов
* `authoritative`  отдают адрес сами
* `recursive` знают, к каким authoritative серверам обратиться, чтобы получить адрес, похоже на прокси,
  обычно кэшируют данные, каждая запись имеет TTL(time to live)

#### Как понять, какой dns сервер отдаёт ip адрес
```
 dig jvns.ca
 ;; ANSWER SECTION:
 jvns.ca.                122     IN      A       104.28.7.94
 jvns.ca.                122     IN      A       104.28.6.94

 ;; AUTHORITY SECTION:
 jvns.ca.                84954   IN      NS      roxy.ns.cloudflare.com.
 jvns.ca.                84954   IN      NS      art.ns.cloudflare.com.

 ;; SERVER: 192.168.4.6#53(192.168.4.6)
```
* `A` значит ip
* `SERVER: 192.168.4.6#53(192.168.4.6)` используемый dns сервер

#### Как увидеть весь путь поиска dns сервера для адреса
Для того, чтобы увидеть какую работу выполняют recursive dns сервера можно вызвать утилиту `dig` с флагом `+trace`
```
dig +trace yandex.ru // делает тоже, самое, что и recursive dns сервер, опрашивает, у кого есть адрес
                     // Сначала идут рут сервера(корневые сервера)
;; global options: +cmd
.                       284396  IN      NS      m.root-servers.net.
.                       284396  IN      NS      h.root-servers.net.
.                       284396  IN      NS      d.root-servers.net.
...
// Потом сервера зоны ру
ru.                     172800  IN      NS      a.dns.ripn.net.
ru.                     172800  IN      NS      b.dns.ripn.net.
ru.                     172800  IN      NS      d.dns.ripn.net.
ru.                     172800  IN      NS      e.dns.ripn.net.
// Потом те, кто относятся к яндексу NS
yandex.ru.              345600  IN      NS      ns1.yandex.ru.
yandex.ru.              345600  IN      NS      ns2.yandex.ru.
// Потом с ip
yandex.ru.              300     IN      A       5.255.255.70
yandex.ru.              300     IN      A       77.88.55.77
yandex.ru.              300     IN      A       77.88.55.70
```


#### Полезные сетевые утилиты
* `dig` утилита для исследования dns серверов, имеет кучу флагов и возможностей, в arch входит в пакет `bind-tools`

