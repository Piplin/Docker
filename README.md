# Piplin - Docker lite
## 系统要求
Docker Engine release 17.04.0+

## 项目克隆

```
$ git clone https://github.com/Piplin/Docker.git piplin-docker
```

## 构建

```
$ cd piplin-docker
$ docker build -t piplin:lite .
```

## 运行

```
$ docker run -d -p 80:80 --name piplin piplin:lite
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
>!!!注意以下操作会清理全部 Piplin Docker 数据，一般用于重新部署时用!!!
```
docker rm -f piplin
docker rmi piplin:lite
```
