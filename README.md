# postgres-db-migrations

Сервис для запуска миграций

## Информация о файлах конфигурации
Все конфигурции можно найти в директории:
```bash
src/postgres-db-migrations/config
```

## Информаци о ENV-параметрах
Имеющиеся env-параметры в проекте:
```
APP_POSTGRESQL_HOST=localhost
APP_POSTGRESQL_PASSWORD=password
APP_POSTGRESQL_USER=postgres
APP_POSTGRESQL_NAME=db
APP_POSTGRESQL_PORT=5432

METADATA_TABLE_PREFIX=v1
SCRIPTS_PATH=migrations
CSRF_ENABLED=True/False
SESSION_COOKIE_SECURE=True/False
```

### Запуск миграций

1. Создайте виртуальное окружение

```bash
python3 -m venv venv
```

2. Активировать виртуальное окружение: 

```bash
source venv/bin/activate
```

3. Установить зависимости: 

```bash
pip3 install -r requirements.txt
```

4. Собрать приложение как модуль:

```bash
python3 setup.py install
```

5. Запусить приложение:
```bash
postgres-db-migrations
```

Приложение запустит sql миграции из директории migrations. Директорию можно изменить через env параметр SCRIPTS_PATH.

Будет создана таблица {METADATA_TABLE_PREFIX}_migrations куда записывается информация об обнаруженых файлах и выполненых миграциях


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
 