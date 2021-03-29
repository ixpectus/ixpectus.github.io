---
title: "Табличные пространства"
date: 2020-07-10T17:47:36+03:00
tags:
  - postgresql
  - tablespaces
summary: "Табличное пространство это указание на каталог в котором хранятся данные.Табличное пространство - средство для организации физического хранения данных. За логическое хранение отвечают базы данных и схемы."
---

* [Слайды](https://edu.postgrespro.ru/dba1/dba1_09_data_tablespaces.pdf)
* [Демо](https://edu.postgrespro.ru/dba1/dba1_09_data_tablespaces.html)

Табличное пространство это указание на каталог в котором хранятся данные.
Табличное пространство - средство для организации физического хранения данных. За логическое хранение отвечают базы данных и схемы.

#### Изучим табличные пространства 
```
select * from pg_tablespace;
  spcname   | spcowner | spcacl | spcoptions
------------+----------+--------+------------
 pg_default |       10 | [NULL] | [NULL]
 pg_global  |       10 | [NULL] | [NULL]
(2 rows)
```

#### Как создать табличное пространство 
* Создадим раздел
  ```
  su postgres
  cd ~
  mkdir tablespace
  ```
* Создадим базу, табличное пространство и назначим её табличное пространство
  ```
  127.0.0.1 postgres@separate_tablespace=# create tablespace ts location '/home/postgres/tablespace';
  CREATE TABLESPACE
  Time: 1.821 ms
  127.0.0.1 postgres@separate_tablespace=# \db
                  List of tablespaces
      Name    |  Owner   |         Location
  ------------+----------+---------------------------
   pg_default | postgres |
   pg_global  | postgres |
   ts         | postgres | /home/postgres/ta
   127.0.0.1 postgres@separate_tablespace=# create database spdb tablespace ts;
   create database
   time: 270.478 ms
  ```
* Можно таблице в базе назначить своё табличное пространство

