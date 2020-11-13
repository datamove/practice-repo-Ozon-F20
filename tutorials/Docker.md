# Docker. 

## Начало работы - hello-world

### Docker pull

```bash
$ docker pull hello-world
Using default tag: latest
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete 
Digest: sha256:8c5aeeb6a5f3ba4883347d3747a7249f491766ca1caa47e5da5dfcf6b9b717c0
Status: Downloaded newer image for hello-world:latest
docker.io/library/hello-world:latest
```

### Версии образов

Скачали версию latest. А какие еще версии доступны?

https://hub.docker.com/_/hello-world?tab=tags

### Повторное скачивание

```bash
$ docker pull hello-world
Using default tag: latest
latest: Pulling from library/hello-world
Digest: sha256:8c5aeeb6a5f3ba4883347d3747a7249f491766ca1caa47e5da5dfcf6b9b717c0
Status: Image is up to date for hello-world:latest
docker.io/library/hello-world:latest
```

### информация об образе

```bash
$ docker images hello-world
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              bf756fb1ae65        10 months ago       13.3kB
```

У образа есть имя, тег, идентификатор

## Запуск

### Создание и запуск контейнера

Контейнер = копия(*) образа + настройки 

(*) на самом деле не копия, но мы еще дойдем до этого

```bash
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

Нужно добавить:

_5. Контейнер остановился._

### Посмотрим, что за контейнер

```bash
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND   CREATED        STATUS                     PORTS    NAMES
54f121ce52e2   hello-world   "/hello"  4 minutes ago  Exited (0) 4 minutes ago            dazzling_hoover
```

У контейнера идентификатор и имя (по умолчанию генерируется что-то)

### повторная команда run

```bash
$ docker run hello-world

Hello from Docker!
...
```

приводит к такому же выводу, но...

```bash
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND   CREATED        STATUS                     PORTS    NAMES
f76547627448   hello-world   "/hello"  About a minut  Exited (0) About a minute ago       hopeful_chaplygin
54f121ce52e2   hello-world   "/hello"  4 minutes ago  Exited (0) 4 minutes ago            dazzling_hoover
```

...приводит к созданию нового контейнера

### Запуск существующего контейнера

```bash
$ docker start dazzling_hoover
dazzling_hoover
```

А где же вывод? Дело в том, что команда start по умолчанию запускает процесс фоном, и не показывает вывод. Однако вывод сохраняется докером и его сожно посмотреть:

```bash
$ docker logs dazzling_hoover

Hello from Docker!
...
```

Вы увидите этот вывод несколько раз - по числу запуска контейнера.

Но можно запустить контейнер с присоединением стандартного вывода к терминалу:

```bash
$ docker start -a dazzling_hoover

Hello from Docker!
...
```

Чтобы автоматически удалять остановившиеся контейнеры каждый раз при запуске команды `run`, используйте опцию `--rm`. 
Чтобы не выводить лог контейнера на экран - опция `run -d`.

Дать контейнеру своё имя - `run --name "hello_$USER"`

Попробуйте сами!

### Работа с долгоиграющим контейнером

Будем запускать сервер nginx



`https://hub.docker.com/_/nginx`

```bash
$ docker run --name "web_$USER" --rm nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
bb79b6b2107f: Pull complete 
5a9f1c0027a7: Pull complete 
b5c20b2b484f: Pull complete 
166a2418f7e8: Pull complete 
1966ea362d23: Pull complete 
Digest: sha256:aeade65e99e5d5e7ce162833636f692354c227ff438556e5f3ed0335b7cc2f1b
Status: Downloaded newer image for nginx:latest
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
```

Так, и что? А ничего. Дело в том, что мы запустили сервер внутри контейнера,
 и именно там он и принимает входящие запросы на порт 80. Снаружи он не видим - докер же изолирует процессы!
 
Давайте для начала заглянем внутрь контейнера, убедимся, что так оно и есть.

Запускаем с опциями "фоном" и "удалитить после остановки", а так же убеждаемся, что все ок (в логе).

```bash
$ docker run -d --rm --name "web_$USER" nginx
f614f3b1b088e8965d52f62f5554725789bb0a3e2a1302689921d9cf0dce13b9

$ docker logs "web_$USER"
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
```

Теперь запускаем интерактивную сессию внутрь контейнера:

```bash
$ docker exec -it "web_$USER" bash
root@f614f3b1b088:/# 
```

Мы как бы залогинились внутрь нашего контейнера - запустили (exec) там bash в интерактивном режиме (-it). Далее, запускаем там веб-клиент и смотрим ответ на порте 80.

```bash
root@f614f3b1b088:/# curl localhost:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
Все отлично, внутри контейнера веб-сервер работает. Выходим из интерактивной сессии exit. А также останавливаем контейнерЖ 

```bash
root@f614f3b1b088:/# exit
exit
$ docker stop "web_$USER"
web_ubuntu
```

Теперь надо пробросить порт 80 из контейнера наружу. За это отвечает опция -p. Чтобы на хосте не возникло конфликта портов при одновременном запуске контейнеров участниками, вот формула запуска, которая обеспечивает уникальный порт для каждого участника. Формула берет номер пользователя в системе (id -u) и прибавляет 1000 для использования непривилигированного порта.

`echo $((1000+`id -u`))`

```bash
$ docker run -d --rm --name "web_$USER" -p $((1000+`id -u`)):80 nginx
e0a4f57151c849fce59966e81b26a862a518b7af59efd5469b18d1184960d63e
$ curl localhost:$((1000+`id -u`))
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

А что там логе nginx?

```bash
$ docker logs "web_$USER"
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
172.17.0.1 - - [10/Nov/2020:14:57:08 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.68.0" "-"
```

Кто-то "постучался" с ip-адреса 172.17.0.1 - это адрес хоста в локальной подсетке, которую докер создал на на хосте.

А виден ли этот сервер из интернета?

```bash
artem@artem-ubuntu2:/media/data/ozon$ curl bigdatamasters.ml:2000
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

Хм, виден, и это скажем так, неприятная неожиданность. Это ведь наш тестовый сервер, нехорошо его выставлять напоказ хакерам всего мира. Давайте исправим:

```bash
$ docker run -d --rm --name "web_$USER" -p 127:0.0.1:$((1000+`id -u`)):80 nginx``
```

Мы привязали порт `$((1000+`id -u`))` на хосте к локальному интерфейсу `localhost`, у которого адрес - 127.0.0.1

Давайте тепрь попробуем как-то изменить начальную страницу nginx, сделаем собственное приветствие. Но ведь это конфигурация nginx, надо ее исправлять.

Давайте снова залезем в контейнер и исправим конфигурацию.

```bash
ubuntu@linux1:~$ docker exec -it "web_$USER" bash
root@7f93288e7218:/# find / -name nginx.conf
/etc/nginx/nginx.conf
find: '/proc/29/map_files': Permission denied
root@7f93288e7218:/# cat /etc/nginx/nginx.conf

user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

Тут ссылка на включаемые файлы:

```bash
root@7f93288e7218:/# ls /etc/nginx/conf.d/*.conf
/etc/nginx/conf.d/default.conf
root@7f93288e7218:/# cat /etc/nginx/conf.d/default.conf
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
```

Ну вот, показывается место, откуда берется заглавная страница сервера:

```bash
root@7f93288e7218:/# cat /usr/share/nginx/html/index.html 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

Йес, это оно!

Давайте поменяем содержимое тега title на что-то ваше. Только вот незадача - в этом образе нет ни одного знакомого редактора (nano, vi, emacs)! На помощь приходит sed:

```bash
root@7f93288e7218:/# sed -i 's/Welcome to nginx/Welcome datamove/' /usr/share/nginx/html/index.html 
root@7f93288e7218:/# cat /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome datamove!</title>
```
Опция -i указывает отредактировать данный файл in place, то есть без потоков ввода-вывода, как мы с вами ранее делали.

Что теперь? надо перестартовать контейнер, и сразу проверяем:

```bash
ubuntu@linux1:~$ docker restart "web_$USER"
web_ubuntu
ubuntu@linux1:~$ curl localhost:$((1000+`id -u`))
<!DOCTYPE html>
<html>
<head>
<title>Welcome datamove!</title>
```

Ок, получилось! А если остановить контейнер и запустить снова?

```bash
$ docker stop "web_$USER"
web_ubuntu
ubuntu@linux1:~$ docker start "web_$USER"
Error response from daemon: No such container: web_ubuntu
Error: failed to start containers: web_ubuntu
```

Ой, мы же использовали опцию `--rm` и уничтожили контейнер со всеми изменениями!

Для того, чтобы решить эту ситуацию, воспользуемся `--mount` - опцией проброса директории или файла с хоста в контейнер.

Начнем с проброса файла.

Загрузите начайльную страницу себе в файл:

```bash
curl -o ~/index.html localhost:80
sed -i 's/Welcome to nginx/Welcome datamove/' ~/index.html
```

Опция --mount

Запустите контейнер, указывая 

```bash
$ docker run -d --rm --name "web_$USER" --mount type=bind,source=/home/$USER/index.html,target=/usr/share/nginx/html/index.html -p 127.0.0.1:$((1000+`id -u`)):80 nginx
```

Заметьте, не имеет значения, существует ли файл с путем /usr/share/nginx/html/index.html в контейнере, или нет. Если существует, то пробрасываемый с хоста файл /home/$USER/index.html "заместит" его.

Проверяем:

```bash
$ curl localhost:2000
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome datamove!</h1>
...
```

Об опции -v.

Это, фактически тоже самое, но с ньюансом и немного большими возможностями.

Вот эквивалент нашей опции:

`-v /home/$USER/index.html:/usr/share/nginx/html/index.html:ro`

Документация советует использовать --mount, но раньше использовалась -v и она много где есть. Документация утверждает, что разница в:
* удобстве --mount. Понятнее стало, что на хосте, а что в контейнере.
* в создании директории на хосте. Если вы указываете папку хоста, которой нет на хосте, -v ее создаст, а --mount выдаст ошибку.

Volumes.

Так же эти опции создают тома докера (docker volumes).

О них в другой раз.
