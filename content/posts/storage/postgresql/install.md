---
title: "Установка postrgesql из исходников"
date: 2020-06-08T11:43:07+03:00
tags:
  - postgresql
  - install
summary : "Установка postgres из исходников"
---

### Установка из исходников 
* [Где скачать](https://www.postgresql.org/ftp/source/v10.0/)
* [Делаю по инструкции](https://edu.postgrespro.ru/dba1/dba1_01_tools_install.html)


#### Сам процесс установки
```
tar -xzf postgresql-10.0.tar.gz
cd ./postgresql-10.0.0
./configure
```
С версией 10.0.0 возникла ошибка при установке 
```
copy_fetch.c:161:1: error: conflicting types for ‘copy_file_range’
 copy_file_range(const char *path, off_t begin, off_t end, bool trunc)
```
Взял версию 10.0.13. Всё установилось, но не был создан пользователь postgres, от имени которого должен запускаться сам postgres. Добавил его руками
```
sudo useradd postgres
sudo passwd postgres
sudo mkdir /home/postgres
sudo chown postgres /home/postgres
su postgres
```
Последним шагом вошёл в систему от имени пользователя postgres и добавил в .bashrc
```
export PGDATA="/usr/local/psql/data"
export PATH=$PATH:/usr/local/pgsql/bin/;
```



##### Добавление psql директории для хранения данных
```
sudo mkdir /usr/local/psql/
sudo chown postgres /usr/local/psql/
```
После добавление директории psql нужно выполнить от имени пользователя postgres `initdb -k`

##### Запуск сервера 
```
pg_ctl -w -l /home/postgres/logfile -D /usr/local/psql/data start
```
Postgresql стартовал
```
ps aux | grep postgres
...
postgres  102850  0.0  0.0 160184  2736 ?        Ss   10:44   0:00 postgres: checkpointer process
postgres  102851  0.0  0.0 160184  5004 ?        Ss   10:44   0:00 postgres: writer process
postgres  102852  0.0  0.0 160184  8516 ?        Ss   10:44   0:00 postgres: wal writer process
postgres  102853  0.0  0.0 160596  5804 ?        Ss   10:44   0:00 postgres: autovacuum launcher process
postgres  102854  0.0  0.0  15132  2644 ?        Ss   10:44   0:00 postgres: stats collector process
...
```
Но не удаётся подключится к нему
```
psql
psql: error: could not connect to server
```
Попробовал скопировать конфиги и поменять `listen_addresses`
```
sudo cp /usr/local/pgsql/share/postgresql.conf.sample /usr/local/pgsql/share/postgresql.conf
```
Нужно было указать host
```
psql -h 127.0.0.1
```
##### Установка расширения pgcrypto 
```
cd ./postgresql-10.13/contrib/pgcrypto
make 
sudo make install
```
Установка прошли успешно, проверяем установленные расширения
```
select * from pg_available_extensions;
   name   | default_version | installed_version |           comment
----------+-----------------+-------------------+------------------------------
 plpgsql  | 1.0             | 1.0               | PL/pgSQL procedural language
 pgcrypto | 1.3             |                   | cryptographic functions
(2 rows)
```
##### Установка всех расширений из директории contrib 
```
cd ./postgresql-10.13/contrib/
sudo make install
        name        | default_version | installed_version |                               comment
--------------------+-----------------+-------------------+----------------------------------------------------------------------
 pg_prewarm         | 1.1             |                   | prewarm relation data
 earthdistance      | 1.1             |                   | calculate great-circle distances on the surface of the Earth
 tsm_system_time    | 1.0             |                   | TABLESAMPLE method which accepts time in milliseconds as a limit
 plpgsql            | 1.0             | 1.0               | PL/pgSQL procedural language
 pg_freespacemap    | 1.2             |                   | examine the free space map (FSM)
 hstore             | 1.4             |                   | data type for storing sets of (key, value) pairs
 pgstattuple        | 1.5             |                   | show tuple-level statistics
 unaccent           | 1.1             |                   | text search dictionary that removes accents
 chkpass            | 1.0             |                   | data type for auto-encrypted passwords
 moddatetime        | 1.0             |                   | functions for tracking last modification time
 tcn                | 1.0             |                   | Triggered change notifications
 citext             | 1.4             |                   | data type for case-insensitive character strings
 pageinspect        | 1.6             |                   | inspect the contents of database pages at a low level
 tsm_system_rows    | 1.0             |                   | TABLESAMPLE method which accepts number of rows as a limit
 amcheck            | 1.0             |                   | functions for verifying relation integrity
 intagg             | 1.1             |                   | integer aggregator and enumerator (obsolete)
 lo                 | 1.1             |                   | Large Object maintenance
 refint             | 1.0             |                   | functions for implementing referential integrity (obsolete)
 btree_gist         | 1.5             |                   | support for indexing common datatypes in GiST
 ltree
 ...

```
##### Остановка сервера 
```
pg_ctl stop -m fast
```
Можно написать просто `pg_ctl stop`, по умолчанию режим остановки как раз буде fast.
Режимы остановки
* fast принудительно завершает все сеансы и записывает на диск изменения из оперативной памяти
* smart ожидает завершения всех сеансов и записывает на диск изменения из оперативной памяти
* immediate принудительно завершает сеансы, при запуске потребуется восстановление
Получается immediate не записывает изменения из оперативной памяти, но не понятно какого рода восстановление понадобится после запуска.
После запуска потребуется прочитать записи из WAL с прошлого checkpoint и применить их
