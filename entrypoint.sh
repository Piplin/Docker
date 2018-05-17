#!/bin/bash
set -eo pipefail

[[ "${DEBUG}" == true ]] && set -x

initialize_system() {
    echo "Initializing Piplin container ..."

    # get global env data
    APP_ENV=${APP_ENV:-development}
    APP_DEBUG=${APP_DEBUG:-true}
    APP_URL=${APP_URL:-http://localhost}

    DB_CONNECTION=${DB_CONNECTION:-sqlite}
    DB_HOST=${DB_HOST:-piplin-mysql}
    DB_DATABASE=${DB_DATABASE:-piplin}
    DB_PORT=${DB_PORT}
    DB_PREFIX=${DB_PREFIX}
    DB_USERNAME=${DB_USERNAME:-piplin}
    DB_PASSWORD=${DB_PASSWORD:-piplinpassword}
    if [[ "${DB_CONNECTION}" = "mysql" ]]; then
        DB_PORT=${DB_PORT:-3306}
    fi

    REDIS_HOST=${REDIS_HOST:-127.0.0.1}
    REDIS_PASSWORD=${REDIS_PASSWORD:-null}
    REDIS_PORT=${REDIS_PORT:-6379}
    REDIS_DATABASE=${REDIS_DATABASE:-0}

    # configure env file
    sed 's,{{APP_ENV}},'"${APP_ENV}"',g' -i /var/www/piplin/.env
    sed 's,{{APP_DEBUG}},'"${APP_DEBUG}"',g' -i /var/www/piplin/.env
    sed 's,{{APP_URL}},'"${APP_URL}"',g' -i /var/www/piplin/.env

    sed 's,{{DB_CONNECTION}},'"${DB_CONNECTION}"',g' -i /var/www/piplin/.env
    sed 's,{{DB_HOST}},'"${DB_HOST}"',g' -i /var/www/piplin/.env
    sed 's,{{DB_DATABASE}},'"${DB_DATABASE}"',g' -i /var/www/piplin/.env
    sed 's,{{DB_PORT}},'"${DB_PORT}"',g' -i /var/www/piplin/.env
    sed 's,{{DB_PREFIX}},'"${DB_PREFIX}"',g' -i /var/www/piplin/.env
    sed 's,{{DB_USERNAME}},'"${DB_USERNAME}"',g' -i /var/www/piplin/.env
    sed 's,{{DB_PASSWORD}},'"${DB_PASSWORD}"',g' -i /var/www/piplin/.env
    if [[ "${DB_CONNECTION}" = "mysql" ]]; then
        sed 's,#DB_DATABASE,DB_DATABASE,g' -i /var/www/piplin/.env
        sed 's,#DB_PORT,DB_PORT,g' -i /var/www/piplin/.env
        sed 's,#DB_PREFIX,DB_PREFIX,g' -i /var/www/piplin/.env
    fi

    sed 's,{{REDIS_HOST}},'"${REDIS_HOST}"',g' -i /var/www/piplin/.env
    sed 's,{{REDIS_PASSWORD}},'"${REDIS_PASSWORD}"',g' -i /var/www/piplin/.env
    sed 's,{{REDIS_PORT}},'"${REDIS_PORT}"',g' -i /var/www/piplin/.env
    sed 's,{{REDIS_DATABASE}},'"${REDIS_DATABASE}"',g' -i /var/www/piplin/.env

    # check redis config
    if ! $(check_redis); then
        rm -rf /etc/supervisor/conf.d/redis.conf
    fi
}

check_database() {
  echo "Attempting to connect to database ..."
  case "${DB_CONNECTION}" in
    mysql)
      prog="mysqladmin -h ${DB_HOST} -u ${DB_USERNAME} ${DB_PASSWORD:+-p$DB_PASSWORD} -P ${DB_PORT} status"
      ;;
  esac
  timeout=60
  while ! ${prog} >/dev/null 2>&1
  do
    timeout=$(( timeout - 1 ))
    if [[ "$timeout" -eq 0 ]]; then
      echo
      echo "Could not connect to database server! Aborting..."
      exit 1
    fi
    echo -n "."
    sleep 1
  done
  echo
}

check_redis() {
    REDIS_HOST=${REDIS_HOST:-127.0.0.1}
    local_host=$([[ "${REDIS_HOST}" = "127.0.0.1" || "${REDIS_HOST}" = "localhost" ]])
    return $local_host
}

check_config() {
    case "${DB_CONNECTION}" in
        mysql)
            checkdbinitmysql
            ;;
        sqlite)
            checkdbinitsqlite
            ;;
    esac
}

checkdbinitmysql() {
    table=users
    if [[ "$(mysql -N -s -h "${DB_HOST}" -u "${DB_USERNAME}" "${DB_PASSWORD:+-p$DB_PASSWORD}" "${DB_DATABASE}" -P "${DB_PORT}" -e \
        "select count(*) from information_schema.tables where \
            table_schema='${DB_DATABASE}' and table_name='${DB_PREFIX}${table}';")" -eq 1 ]]; then
        echo "Table ${DB_PREFIX}${table} exists! ..."
    else
        echo "Table ${DB_PREFIX}${table} does not exist! ..."
        init_db
    fi

}

checkdbinitsqlite() {
    if [ -f database/database.sqlite ]; then 
        echo "database/database.sqlite exists! ..."
    else
        echo "database/database.sqlite does not exist! ..."
        touch database/database.sqlite
        chmod 666 database/database.sqlite
        chmod 777 database
        init_db
    fi
}

init_db() {
    echo "Initializing Piplin database ..."
    if $(check_redis); then
        # temporarily start redis server for database migration
        redis-server &
        migrate_db
        redis-cli shutdown
    else
        migrate_db
    fi
    check_config
}

migrate_db() {
    php artisan migrate
    php artisan db:seed
}

start_system() {
    initialize_system
    check_database
    check_config
    echo "Starting Piplin! ..."
    php artisan config:cache
    /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
}

start_system

exit 0
