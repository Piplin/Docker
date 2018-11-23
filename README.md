# Piplin - Docker lite
## 系统要求
Docker Engine release 17.04.0+

## 项目克隆

```
$ git clone https://github.com/Piplin/Docker.git piplin-docker
```

## 构建

>piplin_ver=v1.0.2 为 piplin 源码的版本号，可在 build 时定义，后期有新版本可直接修改为最新的 release 版本号 [查看最新版本](https://github.com/Piplin/Piplin/releases)

```
$ cd piplin-docker
$ docker build -t piplin:lite . --build-arg piplin_ver=v1.0.2
```

## 运行

```
$ docker run -d -p 80:80 -v piplin:/var/www/piplin --name piplin piplin:lite
```

## 访问

http://127.0.0.1 or http://piplin.app

用户名: piplin
密码: piplin

> 如果你要使用piplin.app访问，请预先在本机hosts配 127.0.0.1 piplin.app

可通过修改下面2个文件中的相关配置进行域名变更（修改后需要重新构建）

```
nginx/piplin.template
.env.docker
```

## 维护
停止容器

`docker stop piplin`

启动容器

`docker start piplin`

查看容器日志

`docker logs piplin`

进入 web 容器

`docker exec -it piplin ash`

## 清理

* 删除容器，容器内的 /var/www/piplin 目录不会被删除，除非进行最后一步的 volume 删除操作

`docker rm -f piplin`

* 删除 build 的镜像

`docker rmi piplin:lite`

>!!!注意以下操作会清理全部 Piplin Docker 数据，并且无法恢复!!!

* 删除 volume

`docker volume rm piplin`