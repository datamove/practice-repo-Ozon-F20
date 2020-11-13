# Dockerfile

В этом тьюториале - о том, как собирать собственные образы для контейнеров.

Заодно сделаем собственный сервер на питоне на основе фреймворка flask.

## Общая картина

Нам понадобится: 

* исходник программы на питоне
* список модулей
* Docker file

### Исходники

Будем работать с приложением на фласк, которое у вас уже должно быть после первого тьюториала.

Только в нем надо заменить определение порта, так как внутри контейнера конфликта портов ну будет. Привязывать сокет к локальному интерфейсу тоже не нужно, даже вредно. Внимание! Замените в старой конфигурации host, port на нижеследующие, а то работать не будет!

```python
port=5000
host="0.0.0.0"
```

### Список модулей

Зайдите в папку flask и выполните:

```bash
(flaskenv) datamove@docker1:~/flask$ pip freeze > requirements.txt
(flaskenv) datamove@docker1:~/flask$ cat requirements.txt
click==7.1.2
Flask==1.1.2
itsdangerous==1.1.0
Jinja2==2.11.2
MarkupSafe==1.1.1
Werkzeug==1.0.1
```

В нашем случае достаточно оставить строчку с Flask, так как остальное - зависимости, они установятся автоматически. Но так как получилось - надежнее, с точки зрения повторяемости.

### Dockerfile

```
FROM ubuntu:20.04
MAINTAINER Artem
RUN apt-get update -y && apt-get install -y python3-pip python-dev build-essential
ADD . /flask-app
WORKDIR /flask-app
RUN pip3 install -r requirements.txt
ENTRYPOINT ["python3", "flask-app.py"]
```

## Давайте разбираться

Эти команды последовательно собирают наш новый образ при запуске docker build (позже)

### FROM

Определяеть базовый образ, в который вы быдете добавлять ваший файлы и что-то доустанавливать

### MAINTAINER

Просто индикативная команда, функционала не несет

### RUN

Запускает команду в контейнере с образом на _данный момент_ резу

Может повторяться.

### ADD

Добавляет файлы с хоста в строящийся образ

### WORKDIR

Определяет текущую директория процесса после запуска. Именно в нее вы попадаете при запуске команды `docker exec -it`

### ENTRYPOINT

команда, которая исполняется при запуске контейнера, вместе а аргументами.

## Запуск сборки

```bash
(flaskenv) datamove@docker1:~/flask$ docker build -t flask-${USER}:latest .
Sending build context to Docker daemon  4.096kB
Step 1/7 : FROM ubuntu:20.04
20.04: Pulling from library/ubuntu
6a5697faee43: Pull complete 
ba13d3bc422b: Pull complete 
a254829d9e55: Pull complete 
Digest: sha256:fff16eea1a8ae92867721d90c59a75652ea66d29c05294e6e2f898704bdb8cf1
Status: Downloaded newer image for ubuntu:20.04
 ---> d70eaf7277ea
Step 2/7 : MAINTAINER Artem
 ---> Running in e43c908f16a6
Removing intermediate container e43c908f16a6
 ---> 0ed1f0e2b429
Step 3/7 : RUN apt-get update -y && apt-get install -y python3-pip python-dev build-essential
 ---> Running in 8ce2eebeeb73
Get:1 http://archive.ubuntu.com/ubuntu focal InRelease [265 kB]
...
done.
Removing intermediate container 8ce2eebeeb73
 ---> 1242712414eb
Step 4/7 : ADD . /flask-app
 ---> 1dc4a7e28d23
Step 5/7 : WORKDIR /flask-app
 ---> Running in d6d2ce26ebd5
Removing intermediate container d6d2ce26ebd5
 ---> 5ce62bcc40ec
Step 6/7 : RUN pip3 install -r requirements.txt
 ---> Running in 4de80c8efd90
Collecting click==7.1.2
  Downloading click-7.1.2-py2.py3-none-any.whl (82 kB)
Collecting Flask==1.1.2
  Downloading Flask-1.1.2-py2.py3-none-any.whl (94 kB)
Collecting itsdangerous==1.1.0
  Downloading itsdangerous-1.1.0-py2.py3-none-any.whl (16 kB)
Collecting Jinja2==2.11.2
  Downloading Jinja2-2.11.2-py2.py3-none-any.whl (125 kB)
Collecting MarkupSafe==1.1.1
  Downloading MarkupSafe-1.1.1-cp38-cp38-manylinux1_x86_64.whl (32 kB)
Collecting Werkzeug==1.0.1
  Downloading Werkzeug-1.0.1-py2.py3-none-any.whl (298 kB)
Installing collected packages: click, MarkupSafe, Jinja2, Werkzeug, itsdangerous, Flask
Successfully installed Flask-1.1.2 Jinja2-2.11.2 MarkupSafe-1.1.1 Werkzeug-1.0.1 click-7.1.2 itsdangerous-1.1.0
Removing intermediate container 4de80c8efd90
 ---> a65953d13f33
Step 7/7 : ENTRYPOINT ["python3", "flask-app.py"]
 ---> Running in d8a09133df3e
Removing intermediate container d8a09133df3e
 ---> d93fcf1fc856
Successfully built d93fcf1fc856
Successfully tagged flask-datamove:latest
```

Сборка завершена. При повторной сборке не так много вывода, так как слои файловой ситстемы образа дробятся на шаги и кежируются!

Появился новый образ flask-datamove

```
(flaskenv) datamove@docker1:~/flask$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
flask-datamove      latest              d93fcf1fc856        2 minutes ago       444MB
ubuntu              20.04               d70eaf7277ea        2 weeks ago         72.9MB
hello-world         latest              bf756fb1ae65        10 months ago       13.3kB
```

### Запускаем

Внимание! Можете первые разы завпускать без опции -d, чтоб видеть, что идет не так. Или пользуйтесь командой docker logs.

```bash
(flaskenv) datamove@docker1:~/flask$ docker run -d --name container-$USER --rm -p 127.0.0.1:$((`id -u` + 1000)):5000 flask-$USER 
de81467f48ccdcbfb59efc373da107d7d0092c7af53e304b648b6dcfc25b7b6a
(flaskenv) datamove@docker1:~/flask$ curl localhost:$((`id -u` + 1000))
Hello world!(flaskenv) datamove@docker1:~/flask$ 
```

## Экстра

### Повторная сборка

Испольует закешированные слои. Но если что-то изменилось в одной строчке, то все последующие команды выполняются заново. Это логично. Например, мы принесли новый код командой ADD, тогда надо выполнить команду RUN pip install -r requirements.txt.

```
(flaskenv) datamove@docker1:~/flask$ docker build -t flask-${USER}:latest .
Sending build context to Docker daemon  4.096kB
Step 1/7 : FROM ubuntu:20.04
 ---> d70eaf7277ea
Step 2/7 : MAINTAINER Artem
 ---> Using cache
 ---> 0ed1f0e2b429
Step 3/7 : RUN apt-get update -y && apt-get install -y python3-pip python-dev build-essential
 ---> Using cache
 ---> 1242712414eb
Step 4/7 : ADD . /flask-app
 ---> 2b096904c98d
Step 5/7 : WORKDIR /flask-app
 ---> Running in 6a906f3f56f6
Removing intermediate container 6a906f3f56f6
 ---> 54a5e1f55337
Step 6/7 : RUN pip3 install -r requirements.txt
 ---> Running in cbce7b9c0ddd
Collecting click==7.1.2
  Downloading click-7.1.2-py2.py3-none-any.whl (82 kB)
Collecting Flask==1.1.2
  Downloading Flask-1.1.2-py2.py3-none-any.whl (94 kB)
Collecting itsdangerous==1.1.0
  Downloading itsdangerous-1.1.0-py2.py3-none-any.whl (16 kB)
Collecting Jinja2==2.11.2
  Downloading Jinja2-2.11.2-py2.py3-none-any.whl (125 kB)
Collecting MarkupSafe==1.1.1
  Downloading MarkupSafe-1.1.1-cp38-cp38-manylinux1_x86_64.whl (32 kB)
Collecting Werkzeug==1.0.1
  Downloading Werkzeug-1.0.1-py2.py3-none-any.whl (298 kB)
Installing collected packages: click, itsdangerous, MarkupSafe, Jinja2, Werkzeug, Flask
Successfully installed Flask-1.1.2 Jinja2-2.11.2 MarkupSafe-1.1.1 Werkzeug-1.0.1 click-7.1.2 itsdangerous-1.1.0
Removing intermediate container cbce7b9c0ddd
 ---> b75ca3823379
Step 7/7 : ENTRYPOINT ["python3", "flask-app.py"]
 ---> Running in 71fe39a5aca7
Removing intermediate container 71fe39a5aca7
 ---> fca0664fc4fa
Successfully built fca0664fc4fa
Successfully tagged flask-datamove:latest
```
