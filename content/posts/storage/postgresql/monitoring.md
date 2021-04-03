---
title: "Мониторинг postgresql"
date: 2020-07-17T10:22:46+03:00
tags:
  - postgresql
  - monitoring
summary: "Статистику о работе postgres можно посмотреть в таблицах pg_stat_activity, pg_stat_all_tables"
---


* [Демо](https://edu.postgrespro.ru/dba1/dba1_11_admin_monitoring.html)
* [Слайды](https://edu.postgrespro.ru/dba1/dba1_11_admin_monitoring.pdf)

### Сбор статистики 
Postgres собирает статистику, за это отвечает процесс stats_collector.  
Посмотреть статистку можно в таблице pg_stat_activity
```
select * from pg_stat_activity
```
Физически статистика хранится в каталоге $PGDATA/pg_stat

#### Вспомогательные таблицы 
* `pg_stat_activity` содержит информацию о работающих процессах
  * в случае если state `idle in transaction`, то это значит, что сеанс начал транзакцию, сейчас ничего не делает и при этом её не завершил
* `pg_stat_all_tables` содержит информацию о работе с таблицами в терминах строк
* `pg_stato_all_tables` содержит информацию о работе с таблицами в терминах таблиц
