---
title: "psql"
date: 2020-06-17T10:34:36+03:00
tags:
  - postgresql
  - psql
summary: "Основные команды psql"
---
### Работа с psql 
* [Демо](https://edu.postgrespro.ru/dba1/dba1_02_tools_psql.html)
* [Слайды](https://edu.postgrespro.ru/dba1/dba1_02_tools_psql.pdf)


#### Команды
`\?` список команд psql  
`\? variables` переменные psql  
`\help` показывает список команды, по которым можно получить документацию, например `help alter table`   
`\q` выход  
`\conninfo` информация о соединении  
```
You are connected to database "postgres" as user "postgres" on host "127.0.0.1" at port "5432".
```  
`\a` включает/выключает выравнивание при выводе  
`\t` включает/выключает вывод заголовков  
`\pset fieldsep ' '` устанавливает другой разделитель для строк, может использоваться для сохранения csv  
`\x` расширенный вывод столбца  
`\set` посмотреть список всех переменных  
`\set VAR1 text` установка значения переменной  
`\echo :VAR1` вывод переменной  
`\d pg_tables` показывает информацию о таблицах    
`\l` показывает список баз данных  
`\c test` подключается к базе данных test (аналог `use test` в mysql)
`\dn` список схем в базе данных (describe namespace)
`\dt` список таблиц

#### Конфигурационные файлы 
##### Общий конфигурационный файл 
`pg_config --sysconfdir` показывает директорию с настройками postgres  
```
pg_config --sysconfdir
/etc/postgresql
```
В моём случае директория `/etc/postgresql` отсутствовала

##### Конфигурационный файл конкретного пользователя
Располагается в `~/.psqlrc`  
Пример файла от [https://github.com/thoughtbot/dotfiles/blob/master/psqlrc](thoughtbot)
```
-- Official docs: http://www.postgresql.org/docs/9.3/static/app-psql.html
-- Unofficial docs: http://robots.thoughtbot.com/improving-the-command-line-postgres-experience

-- Don't display the "helpful" message on startup.
\set QUIET 1
\pset null '[NULL]'

-- http://www.postgresql.org/docs/9.3/static/app-psql.html#APP-PSQL-PROMPTING
\set PROMPT1 '%[%033[1m%]%M %n@%/%R%[%033[0m%]%# '
-- PROMPT2 is printed when the prompt expects more input, like when you type
-- SELECT * FROM<enter>. %R shows what type of input it expects.
\set PROMPT2 '[more] %R > '

-- Show how long each query takes to execute
\timing

-- Use best available output format
\x auto
\set VERBOSITY verbose
\set HISTFILE ~/.psql_history- :DBNAME
\set HISTCONTROL ignoredups
\set COMP_KEYWORD_CASE upper
\unset QUIET
```

#### Формат вывода
##### С выравниванием (используется по умолчанию)
```
127.0.0.1 postgres@postgres=# SELECT schemaname, tablename, tableowner FROM pg_tables LIMIT 5;
 schemaname |    tablename    | tableowner
------------+-----------------+------------
 pg_catalog | pg_statistic    | postgres
 pg_catalog | pg_type         | postgres
 pg_catalog | pg_policy       | postgres
 pg_catalog | pg_authid       | postgres
 pg_catalog | pg_user_mapping | postgres
(5 rows)
```

##### Без выравнивания 
```
\a
SELECT schemaname, tablename, tableowner FROM pg_tables LIMIT 5;
schemaname|tablename|tableowner
pg_catalog|pg_statistic|postgres
pg_catalog|pg_type|postgres
pg_catalog|pg_policy|postgres
pg_catalog|pg_authid|postgres
pg_catalog|pg_user_mapping|postgres
(5 rows)
Time: 1.400 ms
```
##### Без заголовков 
```
\t
Tuples only is on.
127.0.0.1 postgres@postgres=# SELECT schemaname, tablename, tableowner FROM pg_tables LIMIT 5;
pg_catalog|pg_statistic|postgres
pg_catalog|pg_type|postgres
pg_catalog|pg_policy|postgres
pg_catalog|pg_authid|postgres
pg_catalog|pg_user_mapping|postgres
Time: 1.326 ms
```
##### Расширенный(вертикальный вывод столбца)
```
\x
Expanded display is on.
127.0.0.1 postgres@postgres=# SELECT * FROM pg_tables WHERE tablename = 'pg_class';
-[ RECORD 1 ]-----------
schemaname  | pg_catalog
tablename   | pg_class
tableowner  | postgres
tablespace  | [NULL]
hasindexes  | t
hasrules    | f
hastriggers | f
rowsecurity | f
 
Time: 1.754 ms
```

##### Взаимодействие с ОС
* Можно выполнять команды обычного shell
  ```
  \! whoami
  ixpectus
  ```
* Установка переменной окружения
  ```
  => \setenv TEST Hello
  ```
* Запись результатов вывода в файл
  ```
  \o some_file
  127.0.0.1 postgres@postgres=# SELECT * FROM pg_tables WHERE tablename = 'pg_class';
  Time: 1.532 ms
  127.0.0.1 postgres@postgres=#
  ```
  На экран ничего не выведется данные запишутся в файл. Можно поменять разделители и получить csv файл


##### Запуск скриптов
* Как подготовить простой скрипт
  ```
  \t
  Tuples only is off.
  127.0.0.1 postgres@postgres=# \a
  Output format is aligned.
  127.0.0.1 postgres@postgres=# \t \a
  Tuples only is on.
  Output format is unaligned.
  127.0.0.1 postgres@postgres=# \o ~/tmp/psql_script1
  127.0.0.1 postgres@postgres=# SELECT 'SELECT '''||tablename||': ''|| count(*) FROM '||tablename||';'
     FROM pg_tables LIMIT 3;
  Time: 1.119 ms
  ```
* В результате в файле `~/tmp/psql_script1` окажется набор sql запросов
  ```
  SELECT 'pg_statistic: '|| count(*) FROM pg_statistic;
  SELECT 'pg_type: '|| count(*) FROM pg_type;
  SELECT 'pg_policy: '|| count(*) FROM pg_policy;
  ```
* Выполнить их можно разными способами
  * `\i ~/tmp/psql_script1` в запущенном psql
  * подав на вход psql файл
  ```
    psql -h 127.0.0.1 -f ~/tmp/psql_script1
         ?column?
    -------------------
     pg_statistic: 393
    (1 row)
     
    Time: 0.602 ms
       ?column?
    --------------
     pg_type: 375
    (1 row)
     
    Time: 0.212 ms
       ?column?
    --------------
     pg_policy: 0
    (1 row)
     
    Time: 0.220 ms
   ```
   Видно, что тут нет настроек `\t \a` и в заголовке выводится странная запись `?column?`, можно в начале скрипта добавить `\t \a `
   * подать файл на вход можно другим синтаксисом ``psql -h 127.0.0.1 < ~/tmp/psql_script1

##### Переменные
* `\set` посмотреть список всех переменных
* `\set VAR1 text` установка значения переменной
* `\echo :VAR1` вывод переменной
* `\unset :VAR1` сбросить значение переменной
* `SELECT now() AS curr_time \gset` можно результат запроса сразу установить в переменную
  `\echo :curr_time`
* В переменную можно записать запрос и потом его выполнять
  ```
  \set top5 'SELECT tablename, pg_total_relation_size(schemaname||''.''||tablename) AS bytes FROM pg_tables ORDER BY bytes DESC LIMIT 5;'
  :top5
  ```
  Можно полезные запросы записывать в .psqlrc

##### Как подключиться к базе и сделать запрос 
```
psql -h 127.0.0.1 -d test -c 'select count(*) from some_table;';
```
* Флаг `-c` обозначает команду, которую нужно выполнить
* Флаг `-d` обозначает базу, к которой нужно подключиться
