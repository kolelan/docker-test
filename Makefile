# Запускаем консольный скрипт php который выведет приветствие сгенерированное с помощью php в нашу консоль
# 	--rm говорим ему что-бы он удалился после завершения работы
# 	-v монтируем папку нашего окружения внутрь папки сонтейнера (в этом случае в папку /app)
# 	--workdir назначаем рабочую папку относительно которой внутри контейнера будут запускаться приложения
cli:
	docker run --rm -v ${PWD}/bin:/app --workdir=/app php:7.2-cli php app.php

# Запускаем веб приложение на основе образа php:7.2-apache
# 	-p 8080:80 говорит о том, что 80 порт контейнера пробросить на 8080 порт машины в которой запущен контейнер
web:
	docker run --rm -v ${PWD}/public:/var/www/html -p 8080:80 php:7.2-apache

prod-build:
	docker build --file=docker/production/test-php-cli.docker --tag test-php-cli ./

prod-cli:
	docker run --rm test-php-cli php bin/app.php