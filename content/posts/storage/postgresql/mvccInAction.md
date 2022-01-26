---
title: "Особенности MVCC в postgresql на простом примере"
date: 2022-01-25T19:18:38+03:00
tags:
  - postgresql
  - psql
  - experiments
summary: "Как работает mvcc в postgresql на простом примере"
---
### Экспериментируем с mvcc в postgresql 
#### Шаг 1. Создание таблицы 
Создаём таблицу
```sql
create table some_data
(
    id         bigint,
    count      int 
);
```
Размер таблицы
```sql
SELECT pg_size_pretty( pg_total_relation_size('some_data') );
```
Результат
```sql
 pg_size_pretty                
---------------- 
 0 bytes         
```
#### Шаг 2. Создание записи 
```sql
insert into some_data(id, count) values (1, 1);
```
Размер таблицы
```sql
SELECT pg_size_pretty( pg_total_relation_size('some_data') );
```
Результат
```sql
 pg_size_pretty 
----------------
 8192 bytes
```
#### Шаг 3. Многократные апдейты одной строки 
В цикле запускаем обновление строки
```bash
 for i in {01..1000}; do psql -h 0.0.0.0 -d postgres -p 5433 -d some_db -c "update some_data set count=2;"; done
```
Проверяем размер таблицы

```
 pg_size_pretty 
----------------
 8192 bytes 
```
Получается размер таблицы не изменился, хотя согласно модели каждый запрос `update` должен приводить к insert-у новой записи, и delete старой.  
Если размер вообще не изменился, значит должен был работать автовакуум
```sql
select
  autovacuum_count,
  last_autovacuum
from
  pg_stat_user_tables
where
  relname = 'some_data';
```
```sql
 autovacuum_count | last_autovacuum 
------------------+-----------------
                0 | 
```
Но автовакуум не работал, видимо у postgres есть оптимизации на этот случай

#### Шаг 4. Многократные апдейты одной строки c параллельно открытой транзакцией
Открываем транзакцию
```bash
psql -h 0.0.0.0 -d postgres -p 5433 -d some_db
```
```sql
begin transaction;
```
Проверяем количество открытых транзакций
```sql
SELECT 
    pid
    ,datname
    ,usename
    ,application_name
    ,state
FROM pg_stat_activity where datname='some_db';
```
```sql
  pid  |     datname     | usename  | application_name |        state        
-------+-----------------+----------+------------------+---------------------
   105 | assistant_local | postgres | psql             | idle in transaction
 37870 | assistant_local | postgres | psql             | active
```
Здесь видно, что появился процесс со статусом `idle in transaction` - транзакция открыта, но запросов не идёт.  
Посмотрим номер транзакции в открытой транзакции
```sql
select txid_current();
```
```sql
 some_db=# select txid_current();
 txid_current                            
--------------                           
        42600                            
```
Если повторить запрос многократно номер у текущей транзакции не изменится.
Снова запускаем апдейт много раз
```bash
 for i in {01..1000}; do psql -h 0.0.0.0 -d postgres -p 5433 -d some_db -c "update some_data set count=2;"; done
```
Проверяем размер
```
SELECT pg_size_pretty( pg_total_relation_size('some_data') );
```
```
 pg_size_pretty 
----------------
 80 kB
```
И вот тут уже всё сработало ожидаемо, из-за открытой транзакции таблица выросла.  
Когда открыта висящая транзакция `autovacuum` фактически не работает, он приходит и видит, что есть эта старая транзакция и ничего не делает.
```sql
select
  autovacuum_count,
  last_autovacuum
from
  pg_stat_user_tables
where
  relname = 'some_data';
```
```
 autovacuum_count |        last_autovacuum        
------------------+-------------------------------
               16 | 2022-01-25 22:22:13.330422+03
```
Тут видно, что autovacuum ответственно приходит, но без толку.  

```sql
select
  n_live_tup, /*актуальные строки*/
  n_dead_tup  /*удаленные строки*/
from
  pg_stat_all_tables
where
  relname = 'some_data';
```
```sql
 n_live_tup | n_dead_tup 
------------+------------
          1 |       1000
```
Тут видно, что актуальная запись 1 и 1000 мертвых(уже удаленных)

#### Шаг 5. Закрытие висящей транзакции
Делаем `Commit;` в висящей транзакции  
Как только придёт autovacuum, `n_dead_tup` обнулятся
```sql
select
  n_live_tup, /*актуальные строки*/
  n_dead_tup  /*удаленные строки*/
from
  pg_stat_all_tables
where
  relname = 'some_data';
```
```sql
 n_live_tup | n_dead_tup 
------------+------------
          1 |       0
```
А вот размер таблицы останется таким же, размеров в 80кб

#### Мораль 
- Когда висят долгие транзакции autovacuum фактически не работает
- Когда autovacuum не работает 
  - для каждого апдейта создаётся новая запись, 
  - старая не помечается удаленной и не может быть занята новыми данными, так как есть клиенты со старым id транзакций
