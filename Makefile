# Запускаем контейнеры веб приложения в среде разработки
# Контейнеров два, nginx и fpm. А когда будем базу данных поднимать, то их будет три. Может быть и больше если понадобится
# Redis или RabitMQ
# -d в фоновом режиме
# -name manager-apache контейнер будет иметь название manager-apache это нужно знать, когда мы захотим его остановить, иначе придётся останавливать по хеш коду
# -v ${PWD}/manager:/app пробрасываем виртуальный том из нашей операционной системы в контейнер
# -p 8080:80 наш порт 8080 будет попадать на 80 порт контейнера (пробрасываем порты)
# --network=app каждому связанному контейнеру для совместной работы с другими нужна общая сеть.
# последнее слово manager-apache означает какой образ запускаем.
# Сначала устанавливаем сеть, задем поднимаем fpm и после nginx. Порядок важен, поскольку nginx без fpm не поднимется

dev-up:
	docker network create app
	docker run -d --name manager-php-fpm -v ${PWD}/manager:/app --network=app manager-php-fpm
	docker run -d --name manager-nginx -v ${PWD}/manager:/app -p 8080:80 --network=app manager-nginx

# Что-бы удалить контейнер с веб приложением в среде разработки нужно его сначала остановить, а потом удалить
# сначала останавливаем контейнер с nginx, потом с fpm, потом удаляем их, и в конце удаляем сеть app
dev-down:
	docker stop manager-nginx
	docker stop manager-php-fpm
	docker rm manager-nginx
	docker rm manager-php-fpm
	docker network remove app

# Перед тем как запускать и останавливать контейнеры их нужно собрать
# --file=где находится dockerfile
# --tag manager-php-cli|manager-apache как будет наыватся образ
# manager/docker/development какие файлы отправить в докер на сборку. В случае с разработкой мы отправляем в докер
# только докерфайлы, потому что всё остальное мы примонтируем чере виртуальный том во время запуска образа, а в случае,
# если среда рабочая, то будем отправлять все файлы, потому что мы их будем собирать с инструкцией COPY иначе докер
# сборщик не получит эти файлы и не соберёт их в образ
dev-build:
	docker build --file=manager/docker/development/php-fpm.docker --tag manager-php-fpm manager/docker/development
	docker build --file=manager/docker/development/nginx.docker --tag manager-nginx manager/docker/development
	docker build --file=manager/docker/development/php-cli.docker --tag manager-php-cli manager/docker/development

# Запуск контейнера консольного приложения в режиме разработки
# --rm удалить контейнер после завершения работы
# -v ${PWD}/manager:/app пробросить в контейнер в папку /app все файлы и папки из директории manager
# manager-php-cli запустить собранный образ manager-php-cli
# php bin/app.php запустить команду php
dev-cli:
	docker run --rm -v ${PWD}/manager:/app manager-php-cli php bin/app.php

# В режиме готового приложения не прокидываем виртуальный том, потому что в собранном образе уже есть все файлы
# -p 80:80 пробрасывамем 80 порт контейнера на 80 порт нашей операционной системы, потому что на рабочем сервере
# мы слушаем уже не 8080 порт а 80.
prod-up:
	docker network create app
	docker run -d --name managerphp-fpm  manager-php-fpm
	docker run -d --name manager-nginx -p 80:80 manager-nginx

# ничем от dev-down не отличается, просто для порядка
prod-down:
	docker stop manager-nginx
	docker stop manager-php-fpm
	docker rm manager-nginx
	docker rm manager-php-fpm
	docker network remove app

# В режиме готового приложения прокидываем всю папку manager а не только докерфайлы
# все лишние файлы, например папку vender в докер сборщик не попадут, потому, что мы их исключим потом в файле .dockerignore
prod-build:
	docker build --file=manager/docker/production/php-fpm.docker --tag manager-php-fpm manager
	docker build --file=manager/docker/production/nginx.docker --tag manager-nginx manager
	docker build --file=manager/docker/production/php-cli.docker --tag manager-php-cli manager

# -v ${PWD}/manager:/app  делать не нужно, потому что там уже есть все файлы
prod-cli:
	docker run --rm manager-php-cli php bin/app.php