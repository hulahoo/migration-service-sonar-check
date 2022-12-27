# postgres-db-migrations

Репа для хранения схем миграции, централизовано накатывает миграции на БД

## Создание своего образа

1. Для того чтобы создать свой образ на основе Postgres, в репозитории реализован Dockerfile, описывающий создание образа и запись данных в таблицы

2. Чтобы собрать образ нужно выполнить команду:
```bash
docker build -t rshb-cti-db-postgres .
```

3. Привязываем тег к нашему образу:
```bash
docker tag rshb-cti-db-postgres:latest rshb-cti-db-postgres:staging
```

4. Для использвания выше созданного образа в своих docker-compose файлах, нужно приписать следующее:
```yaml
services:
    ...
    db:
        image: rshb-cti-db-postgres:staging    
```
