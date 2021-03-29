---
title: "Системный каталог"
date: 2020-07-09T10:11:39+03:00
tags:
  - postgresql
  - system catalog
summary: "В postgres, как и в других базах данных есть таблицы, которые хранят информацию о всех сущностях в базе"
---
В postgres, как и в других базах данных есть таблицы, которые хранят информацию о всех сущностях в базе

#### Таблицы системного каталога 
* `pg_database` хранит информацию о базах данных
* `pg_namespace` о схемах
* `pg_class` о таблицах, индексах, последовательностях(о всех отношениях relations)
* `pg_views` о views
* `pg_attribute` колонки таблиц

#### Команды psql для получения доступа к системному каталогу
* `\d*` все "отношения"
* `\dt` таблицы
* `\dv` views
* `\dt+` расширенная информация о таблицах
* `\d some_table` получаем информацию о конкретной таблице
* `\d+ some_table` получаем расширенную информацию о конкретной таблице
* `\df`  функции, например `\df pg_catalog.*`
* `\sf` показывает тело функции
  ```
  \sf pg_catalog.xmlexists
  CREATE OR REPLACE FUNCTION pg_catalog."xmlexists"(text, xml)
   RETURNS boolean
   LANGUAGE internal
   IMMUTABLE PARALLEL SAFE STRICT
  AS $function$xmlexists$function$
  ```
#### OID 
У всех таблиц системного каталоге есть поле `oid`, обозначает уникальный идентификатор. Поле по умолчанию не выводится.  
Чтобы вывелось нужно указать явно  
```
select oid,* from pg_namespace;
```

#### ECHO_HIDDEN 
Можно посмотреть, какие именно команды sql выполняют команды psql, для этого нужно установить флаг
```
\set ECHO_HIDDEN on
```
Например
```
127.0.0.1 postgres@test=# \dt
********* QUERY **********
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','p','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname <> 'information_schema'
      AND n.nspname !~ '^pg_toast'
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1,2;
**************************
```
##### Запросы при получении списка колонок 
А вот `\d texts` превратится в большое количество запросов

##### Получение списка колонок таблиц 
Так можно получить список всех колонок из всех таблиц
```
 select relname,attname from pg_class pc join pg_attribute pa on pa.attrelid=pc.oid;
```
Так можно получить все несистемные схемы
```
 select nspname from pg_namespace where nspname !~ '^(pg|information).\*';
```

```
 select 
   pn.nspname,relname,attname 
 from 
  pg_class pc join pg_attribute pa on pa.attrelid=pc.oid join pg_namespace pn on pn.oid = pc.relnamespace
 where pn.nspname !~ '^(pg|information).\*';
```
##### Как получить колонки только одной таблицы 
```
SELECT a.attname
FROM pg_attribute a
WHERE a.attrelid = 'texts'::regclass
AND a.attnum > 0;
```
