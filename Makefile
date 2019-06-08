# Запускаем консольный контейнер
cli:
	docker run --rm -v ${PWD}/bin:/app --workdir=/app php:7.2-cli php app.php

#Запускаем веб приложение
web:
	docker run --rm -v ${PWD}/public:/var/www/html -p 8080:80 php:7.2-apache