---
title: "Конфигурирование postgresql"
date: 2020-06-20T21:41:17+03:00
tags:
  - postgresql
---

* [Демо](https://edu.postgrespro.ru/dba1/dba1_03_tools_configuration.html)
* [Слайды](https://edu.postgrespro.ru/dba1/dba1_03_tools_configuration.pdf)

#### Посмотреть настройки конфигурационного файла 
Можно прямо в postgres, есть табличка, которая соответствует конфигурационному файлу
```
select * from pg_file_settings;
              sourcefile              | sourceline | seqno |            name            |      setting       | applied | error
--------------------------------------+------------+-------+----------------------------+--------------------+---------+--------
 /usr/local/psql/data/postgresql.conf |         64 |     1 | max_connections            | 100                | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        113 |     2 | shared_buffers             | 128MB              | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        127 |     3 | dynamic_shared_memory_type | posix              | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        461 |     4 | log_timezone               | Europe/Moscow      | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        565 |     5 | datestyle                  | iso, mdy           | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        567 |     6 | timezone                   | Europe/Moscow      | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        580 |     7 | lc_messages                | en_US.UTF-8        | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        582 |     8 | lc_monetary                | en_US.UTF-8        | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        583 |     9 | lc_numeric                 | en_US.UTF-8        | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        584 |    10 | lc_time                    | en_US.UTF-8        | t       | [NULL]
 /usr/local/psql/data/postgresql.conf |        587 |    11 | default_text_search_config | pg_catalog.english | t       | [NULL]
(11 rows)
```
Столбец applied везде установлен true, что говорит о том, что в конфигурационном файле значение установлено, но в текущей сессии вполне может быть другое значение этого параметра.


### Где посмотреть конфигурационные параметры текущей сессии
* Посмотреть все текущие настройки(там много всего)
  ```
  select * from pg_settings;
  ```
* Узнать имя текущего конфигурационного файла  
  ```
  select * from pg_settings where name='config_file';
  -[ RECORD 1 ]---+-------------------------------------------
  name            | config_file
  setting         | /usr/local/psql/data/postgresql.conf
  unit            | [NULL]
  category        | File Locations
  short_desc      | Sets the server's main configuration file.
  extra_desc      | [NULL]
  context         | postmaster
  vartype         | string
  source          | override
  min_val         | [NULL]
  max_val         | [NULL]
  enumvals        | [NULL]
  boot_val        | [NULL]
  reset_val       | /usr/local/psql/data/postgresql.conf
  sourcefile      | [NULL]
  sourceline      | [NULL]
  pending_restart | f
  ```
  Видим, что файл расположен в `/usr/local/psql/data/postgresql.conf`
  * `setting` текущее значение параметра
  * `reset_val` значение по умолчанию, если выполнить команду `reset` то оно будет установлено
  * `pending_restart` обозначает необходимость перезапуска сервера для того, чтобы конфигурационный параметр применился(в нашей случае false, значит перезагружать сервер нет необходимости)
* Узнать значение параметра `work_mem` - максимальное количество памяти, которое может быть выделено для текущего процесса
```
select * from pg_settings where name='work_mem'\gx
-[ RECORD 1 ]---+----------------------------------------------------------------------------------------------------------------------
name            | work_mem
setting         | 4096
unit            | kB
category        | Resource Usage / Memory
short_desc      | Sets the maximum memory to be used for query workspaces.
extra_desc      | This much memory can be used by each internal sort operation and hash table before switching to temporary disk files.
context         | user
vartype         | integer
source          | default
min_val         | 64
max_val         | 2147483647
enumvals        | [NULL]
boot_val        | 4096
reset_val       | 4096
sourcefile      | [NULL]
sourceline      | [NULL]
pending_restart | f
```
  * `setting` текущее значение параметра
  * `unit` единица измерения, в нашем случае kB
  * `reset_val` если параметр изменен во время сеанса, то можно вызвать `reset` и будет установлено это значение
  * `pending_restart` обозначает необходимость перезапуска сервера для того, чтобы конфигурационный параметр применился(в нашей случае false, значит перезагружать сервер нет необходимости)
  * `context` установлен `user`, обозначает, что пользователь в рамках своей сессии может изменить значение дананого параметра
  * `boot_val` значение по умолчанию
  * `min_val`, `max_val` минимальное-максимальное значение параметра
* Параметр `context`
  * Можно посмотреть список возможных значений параметра context
  ```
    select distinct context from pg_settings;
          context
    -------------------
     postmaster
     superuser-backend
     user
     internal
     backend
     sighup
     superuser
    (7 rows)
  ```
    * `internal` изменить нельзя никогда
    * `user` может изменить пользователь в рамках своей сессии
    * `postmaster` нужен перезапуск сервера для изменения значения
    * `sighup` требуется перечитать файлы конфигурации
    * `superuser` суперпользователь может изменить для своего сеанса

#### Попробуем изменить значения параметра `work_mem`
* Изменим значение в конфигурационном файле
  ```
  work_mem = 24MB
  ```
* Посмотрим значения в отображении `pg_file_settings`
  ```
  127.0.0.1 postgres@postgres=# select * from pg_file_settings where name='work_mem';
                sourcefile              | sourceline | seqno |   name   | setting | applied | error
  --------------------------------------+------------+-------+----------+---------+---------+--------
   /usr/local/psql/data/postgresql.conf |        122 |     3 | work_mem | 24MB    | t       | [NULL]
  (1 row)
  ```
  Видим, что значение установлено
* Посмотрим значение в `pg_settings`
  ```
  127.0.0.1 postgres@postgres=# select setting from pg_settings where name='work_mem'\gx
  -[ RECORD 1 ]-
  setting | 4096
  ```
  Значение не поменялось
* Для того, чтобы изменить значение нужно выполнить  
  ```
  select pg_reload_conf();
  ```
* Посмотрим на параметр
  ```
  127.0.0.1 postgres@postgres=# select setting from pg_settings where name='work_mem'\gx
  -[ RECORD 1 ]--
  setting | 24576
  ```
  Изменился!
 
#### Изменение параметров без ручной правки конфигурационного файла 
Есть команда `ALTER SYSTEM`, которая позволяет изменить значение параметра прямо в sql. Будет создан новый конфигурационный файл `postgresql.auto.conf`, значения параметров там будут перекрывать значения в `postgresql.conf`
* Изменим `work_mem`
  ```
  127.0.0.1 postgres@postgres=# alter system set work_mem to '10MB';
  ALTER SYSTEM
  Time: 5.099 ms
  ```
* Смотрим, не изменилось
  ```
  127.0.0.1 postgres@postgres=# select setting from pg_settings where name='work_mem'\gx
  -[ RECORD 1 ]--
  setting | 24576
  ```
* Нужно обновить конфиги `select pg_reload_conf` и значение изменится
* `alter system reset work_mem` очистит значение

#### Изменение значений параметров на время сессии
* `SET work_mem to '26MB'`
* Проверим, видим, что значение изменилось, и что источник ``
  ```
  127.0.0.1 postgres@postgres=# select * from pg_settings where name='work_mem'\gx
  -[ RECORD 1 ]---+----------------------------------------------------------------------------------------------------------------------
  name            | work_mem
  setting         | 26624
  unit            | kB
  category        | Resource Usage / Memory
  short_desc      | Sets the maximum memory to be used for query workspaces.
  extra_desc      | This much memory can be used by each internal sort operation and hash table before switching to temporary disk files.
  context         | user
  vartype         | integer
  source          | session
  ```

