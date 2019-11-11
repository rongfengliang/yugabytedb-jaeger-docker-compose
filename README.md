# yugabytedb as jaeger storage

current can't works,still find solution


## how to runngin


* start docker-compose yugabytedb service

```code
docker-compose up -d
```

* create schema

```code
cat schema.sql | cqlsh
```


* init ysql

```code
docker-compose exec yb-master bash -c "YB_ENABLED_IN_POSTGRES=1 FLAGS_pggate_master_addresses=yb-master-n1:7100 /home/yugabyte/postgres/bin/initdb -D /tmp/yb_pg_initdb_tmp_data_dir -U postgres"
```

## works  with plv8  extension

> not good current not support `CREATE LANGUAGE`

*  copy static library && control files (include sql  fieles)

```code
pg-config =  /home/yugabyte/postgres/bin
alias yb_pg_config=/home/yugabyte/postgres/bin/pg_config

share library:

ls "$(yb_pg_config --pkglibdir)"


cp /home/yugabyte/postgres/lib 

docker cp plv8/plv8-2.3.12.so   yb-tserver-n1:/home/yugabyte/postgres/lib
docker cp plv8/plv8-2.3.12.so   yb-tserver-n2:/home/yugabyte/postgres/lib


extension:
ls "$(yb_pg_config --sharedir)"/extension/
cp /home/yugabyte/postgres/share/extension/

docker cp plv8/sql/.   yb-tserver-n1:/home/yugabyte/postgres/share/extension
docker cp plv8/sql/.   yb-tserver-n2:/home/yugabyte/postgres/share/extension
```

## work with pg_hashids (it works)

* copy extension

```code
cp /home/yugabyte/postgres/lib 

docker cp hashids/pg_hashids.so   yb-tserver-n1:/home/yugabyte/postgres/lib
docker cp hashids/pg_hashids.so   yb-tserver-n2:/home/yugabyte/postgres/lib


extension:
ls "$(yb_pg_config --sharedir)"/extension/
cp /home/yugabyte/postgres/share/extension/

docker cp hashids/extension/.  yb-tserver-n1:/home/yugabyte/postgres/share/extension
docker cp hashids/extension/.   yb-tserver-n2:/home/yugabyte/postgres/share/extension
```