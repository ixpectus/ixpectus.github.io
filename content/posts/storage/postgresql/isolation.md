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
127.0.0.1 postgres@test=# select *, xmin, xmax from texts;
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
 
 
