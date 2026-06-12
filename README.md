# Admin API

管理后台API接口（Rails 8.1 API-only）。

## 项目结构

```
admin_api/
├── app/
│   ├── controllers/api/v1/   # API 接口
│   ├── models/               # 数据模型
│   ├── jobs/                 # 异步任务
│   └── services/             # 业务逻辑
├── config/                   # 配置
├── db/                       # 数据库
└── lib/tasks/                # rake 命令
```

## 模块说明

### 1. 接口 (`app/controllers/api/v1/movies_controller.rb`)

提供 3 个接口：

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/movies` | 电影列表（支持搜索、筛选、分页） |
| GET | `/api/v1/movies/:id` | 电影详情 |
| GET | `/api/v1/movies/export` | 导出 Excel |

### 2. 模型 (`app/models/movie.rb`)

`Movie` 数据模型，包含：

- 字段校验（名称必填、链接唯一、评分0-10）
- `Movie.filter_by(params)` 类方法 — 根据查询参数筛选电影

### 3. 爬虫模块 (`app/services/scrape_center/`)

抓取 https://ssr1.scrape.center 的电影数据：

| 文件 | 职责 |
|------|------|
| `client.rb` | HTTP 客户端，发请求抓网页 |
| `list_parser.rb` | 解析列表页，提取电影基本信息 |
| `detail_parser.rb` | 解析详情页，提取剧情、导演、演员等 |
| `importer.rb` | 把抓取的数据保存到数据库 |

### 4. 异步任务 (`app/jobs/`)

爬取走异步队列（Solid Queue）：

- `ScrapeListJob` — 抓取一页列表，并把每部电影的详情抓取丢到队列
- `ScrapeDetailJob` — 抓取一部电影的详情页并保存

### 5. Excel 导出 (`app/services/movie_exporter.rb`)

用 `caxlsx` gem 生成 Excel 文件，把筛选后的电影列表导出。

### 6. OSS 上传 (`app/services/oss_center/client.rb`)

阿里云 OSS 文件上传客户端（占位，未启用）。

## 常用命令

### 启动服务

```bash
# 启动 API 服务（默认端口 3000）
bin/rails server

# 启动队列消费者（爬虫任务执行需要）
bin/jobs
```

### 爬虫命令

```bash
# 爬取第 1-10 页（默认）
rake scrape:ssr1

# 爬取指定页数（第 1-5 页）
rake "scrape:ssr1[1,5]"

# 查看爬取进度
rake scrape:progress

# 清除所有数据重新爬
CONFIRM=yes rake scrape:reset
```

### 数据库

```bash
# 创建数据库
bin/rails db:create

# 执行迁移
bin/rails db:migrate

## 环境变量

复制 `.env.example` 为 `.env`，填入配置：

```
DB_HOST=数据库地址
DB_PORT=5432
DB_USERNAME=用户名
DB_PASSWORD=密码
```
