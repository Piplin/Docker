# Piplin - Docker
## 系统要求
Docker Engine release 17.04.0+

## 项目克隆

```
$ git clone https://github.com/Piplin/Docker.git piplin-docker
```

## 构建

```
$ cd piplin-docker
$ docker-compose -p piplin build
```

## 运行

```
$ docker-compose -p piplin up -d

```

## 访问

http://127.0.0.1 or http://piplin.app

用户名: piplin
密码: piplin

> 如果你要使用piplin.app访问，请预先在本机hosts配 127.0.0.1 piplin.app

可通过修改下面2个文件中的相关配置进行域名变更（建议在初始化之前修改）
```
web/nginx/piplin.template
env
```

## 维护
停止容器

`docker-compose -p piplin stop`

启动容器

`docker-compose -p piplin start`

查看容器日志

`docker-compose -p piplin logs`

进入 web 容器

`docker-compose -p piplin exec web bash`

## 清理
>!!!注意以下操作会清理全部 Piplin Docker 数据，一般用于重新部署时用!!!
```
docker-compose -p piplin down --volumes
docker rmi -f piplin_web
```
