---
title: "Изоляция и многоверсионность в postgresql"
date: 2020-06-21T14:06:19+03:00
tags:
  - postgresql
  - isolation
  - mvcc
  - acid
---

* [Демо](https://edu.postgrespro.ru/dba1/dba1_05_arch_mvcc.html)
* [Слайды](https://edu.postgrespro.ru/dba1/dba1_05_arch_mvcc.pdf)

#### MVCC и postrges 
Для того, чтобы писатели не блокировали читателей в postgres используется MVCC - multiversion concurrency control. Клиент может читать данные, пока кто-то другой эти данные меняет.
Каждое изменение строки приводит к появлению новой версии строки в файле данных.
Каждый запрос работает со снимком данных.    
Снимок включает в себя
* номер последней активной транзакции
* список активных транзакций
Список активных транзакций нужен для того, чтобы случайно не считать данные, которые находятся ещё в процессе изменения

#### Vacuum 
Каждое изменение данных приводит к появлению новой строки данных. Кажется, что изменение одного int может привести к появлению новой строки, в которой потенциально может быть гораздо больше данных.  
Со временем данные становятся никому не нужно, поскольку нет процессов, которые работают со снимком, включающих в себя эти данные.  
Удалением неактуальных данных занимается процесс auto vacuum, а точнее 2 процесса
* `autovacuum launcher` следит за количеством строк, которые надо удалить и при необходимости вызвает
* `autovacuum worker` непосредственно занимается удалением неактуальных данных

#### Команды 
* `SELECT txid_current();` возвращает id текущей транзакции, что интересно, каждый следующий вызов увеличивает число
* `select xmax, xmin from <table_name>` можно увидеть значения xmax и xmin для строк в таблице
  * `xmin` минимальный номер транзакции, для которой актуальна эта версия строки
  * `xmax` максимальный номер транзакции, для которой актуальна эта версия строки

#### Поэкспериментируем  
* Создадим базу и таблицу
  ```
   create database test;
   create table texts(s1 text,s2 text);
  ```
* Посмотрим xmin, xmax
  ```
  127.0.0.1 postgres@test=# select xmax,xmin from texts;
   xmax | xmin
  ------+------
  (0 rows)
  ```
  Ничего нет, что логично
* Вставим строку и посмотрим на xmin, xmax
  ```
  127.0.0.1 postgres@test=# insert into texts(s1,s2) values('qqq', 'wwwwwww');
  INSERT 0 1
  127.0.0.1 postgres@test=# select *, xmin, xmax from texts;
   s1  |   s2    | xmin | xmax
  -----+---------+------+------
   qqq | wwwwwww |  565 |    0
  (1 row)
  ```
  xmin установлен, а xmax = 0, что говорит о том, что данные актуальны
* Обновим строку и снова посмотрим
  ```
  127.0.0.1 postgres@test=# update texts set s2='wwwwww' where s1='qqq';
  UPDATE 1
  Time: 1.329 ms
  127.0.0.1 postgres@test=# select *, xmin, xmax from texts;
   s1  |   s2   | xmin | xmax
  -----+--------+------+------
   qqq | wwwwww |  566 |    0
  (1 row)
   
  Time: 0.626 ms
  ```
  Видно, что версия обновилась, но старых данных не видно, интересно
* Попробуем в 2-х терминалах  
  * Терминал 1
    ```
    127.0.0.1 postgres@test=# begin transaction;
    BEGIN
    Time: 0.364 ms
    127.0.0.1 postgres@test=# select *, xmin, xmax from texts;
     s1  |   s2   | xmin | xmax
    -----+--------+------+------
     qqq | wwwwww |  566 |    0
    (1 row)
     
    Time: 0.564 ms
    127.0.0.1 postgres@test=# update texts set s2='yyy' where s1='qqq';
    UPDATE 1
    Time: 0.627 ms
    127.0.0.1 postgres@test=# select *, xmin, xmax from texts;
     s1  | s2  | xmin | xmax
    -----+-----+------+------
     qqq | yyy |  567 |    0
    (1 row)
     
    Time: 0.481 ms
    ```
  * Терминал 2
    ```
    begin transaction;
    127.0.0.1 postgres@test=# select *, xmin, xmax from texts;
     s1  |   s2   | xmin | xmax
    -----+--------+------+------
     qqq | wwwwww |  566 |  567
    (1 row)
    select txid_current();
     txid_current
    --------------
              568
     ``` 
 В 1 терминале начали транзакцию, изменили значение и прошлого значения там уже не видно. А вот во втором терминале видно, что xmax=567, что говорит о том, что значение уже неактуально, но в первой транзакции ещё не было коммита. После того, как в первой сессии произойдёт commit, появится возможность прочитать обновленные данные.
* Что будет, если в первом терминале сделать rollback ? Я предположил, что в этом случае появится новая версия строки с большим xmin и xmax=0, но в первом терминале после rollback я увидел следующее
```
127.0.0.1 postgres@test=# update texts set s2='zzz' where s1='qqq';
UPDATE 1
Time: 0.228 ms
127.0.0.1 postgres@test=# rollback;
ROLLBACK
Time: 0.187 ms
127.0.0.1 postgres@test=# select * , xmin, xmax from texts;
 s1  | s2  | xmin | xmax
-----+-----+------+------
 qqq | yyy |  567 |  569
(1 row)
```

В момент выполнения этого запроса во втором терминале
```
127.0.0.1 postgres@test=# select txid_current();
 txid_current
--------------
          568
(1 row)
```
После rollback во втором терминале xmin и xmax не изменились. Не очень понятно, что значит xmax в таком случае
 
#### Уровни изоляции транзакций
* Read Commited
* Repeatable Read
* Serializable  

Можно установить уровень транзакции при старте транзакции
```
begin isolation level repeatable read;
```


#### Эксперимент со счётчиком
Судя по тому, что я узнал если сделать таблицу с одной строчкой и 10 тысяч раз её изменить, то размер таблицы увеличится, проверим
* Создадим таблицу и вставим строку
```
127.0.0.1 postgres@test=# create table some_table(id int, counter int, text1 text, text2 text);
CREATE TABLE
Time: 12.475 ms
127.0.0.1 postgres@test=# insert into some_table(id, counter, text1, text2) values(1,0,'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq','wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww');
INSERT 0 1
Time: 2.613 ms
```
* Посмотрим размер таблицы
```
127.0.0.1 postgres@test=# SELECT pg_size_pretty( pg_total_relation_size('some_table') );
 pg_size_pretty
----------------
 16 kB
(1 row)
```
* Посмотрим файлы на диске
```
ixpectus# ls -lh $PGDATA
6 postgres postgres 4.0K Jun 21 22:06 base
drwx------ 2 postgres postgres 4.0K Jun 21 22:08 global
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_commit_ts
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_dynshmem
-rw------- 1 postgres postgres 4.5K Jun 16 10:42 pg_hba.conf
-rw------- 1 postgres postgres 1.6K Jun 16 10:42 pg_ident.conf
drwx------ 4 postgres postgres 4.0K Jun 23 10:23 pg_logical
drwx------ 4 postgres postgres 4.0K Jun 16 10:42 pg_multixact
drwx------ 2 postgres postgres 4.0K Jun 21 13:40 pg_notify
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_replslot
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_serial
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_snapshots
drwx------ 2 postgres postgres 4.0K Jun 21 13:40 pg_stat
drwx------ 2 postgres postgres 4.0K Jun 23 10:25 pg_stat_tmp
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_subtrans
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_tblspc
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_twophase
-rw------- 1 postgres postgres    3 Jun 16 10:42 PG_VERSION
drwx------ 3 postgres postgres 4.0K Jun 16 10:42 pg_wal
drwx------ 2 postgres postgres 4.0K Jun 16 10:42 pg_xact
-rw------- 1 postgres postgres  106 Jun 20 22:25 postgresql.auto.conf
-rw------- 1 postgres postgres  23K Jun 20 22:31 postgresql.conf
-rw------- 1 postgres postgres   30 Jun 20 22:34 postmaster.opts
-rw------- 1 postgres postgres   81 Jun 21 13:40 postmaster.pid
```
* Увеличим counter 10000 раз
```
for i in {01..10000}; do psql -h 127.0.0.1 -d test -c 'update some_table set counter=counter+1 where id=1';done;
```
* Размер таблицы не изменился практически
```
127.0.0.1 postgres@test=# SELECT pg_size_pretty( pg_total_relation_size('some_table') );
 pg_size_pretty
----------------
 16 kB
(1 row)
```
Хотя казалось бы для каждого update должна была создаваться запись с новой версией. Возможно vacuum успевал работать  
Размер файлов на диске также существенно не изменился  
* Попробуем запустить скрипт немного по-другому
```
 for i in {01..10000}; do psql -h 127.0.0.1 -d test -c 'update some_table set counter=counter+1 where id=1' &;done;
```
В конце команды добавил знак `&`, что приведёт к тому, что команды начнут запускаться не последовательно, а параллельно
```
127.0.0.1 postgres@test=# SELECT pg_size_pretty( pg_total_relation_size('some_table') );
 pg_size_pretty
----------------
 1008 kB
(1 row)
```
И размер базы вырос в 1000 раз, хотя там по-прежнему одна строка
* Теперь увеличим счётчик еще на 10000 раз и посмотрим, какие файлы на диске изменились по размеру  
Текущее состояние
```
du -h | sort -h
4.0K    ./pg_commit_ts
4.0K    ./pg_dynshmem
4.0K    ./pg_logical/mappings
4.0K    ./pg_logical/snapshots
4.0K    ./pg_replslot
4.0K    ./pg_serial
4.0K    ./pg_snapshots
4.0K    ./pg_stat
4.0K    ./pg_tblspc
4.0K    ./pg_twophase
4.0K    ./pg_wal/archive_status
12K     ./pg_multixact/members
12K     ./pg_multixact/offsets
12K     ./pg_notify
12K     ./pg_xact
16K     ./pg_logical
28K     ./pg_multixact
32K     ./pg_stat_tmp
92K     ./pg_subtrans
584K    ./global
7.1M    ./base/1
7.1M    ./base/12296
7.2M    ./base/12297
8.2M    ./base/16384
17M     ./pg_wal
30M     ./base
```
После увеличения счётчика на 10000 раз размер базы не увеличился, т.к. вероятно пришёл vacuum и удалил старые строки. Увеличим сразу на 20000. Размер базы вообще уменьшился и размер файлов тоже существенно не увеличился
```
127.0.0.1 postgres@test=# SELECT pg_size_pretty( pg_total_relation_size('some_table') );
 pg_size_pretty
----------------
 280 kB
(1 row)
```

##### Мораль
В postgresql всё работает не так прямолинейно, и даже если размер таблицы увеличился по размеру, он может стать меньше даже без vacuum full

