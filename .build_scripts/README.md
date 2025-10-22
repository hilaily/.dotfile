# Scripts 使用说明

这个目录包含项目的构建和版本管理脚本。

## 文件说明

- `Makefile`: 构建、推送 Docker 镜像和版本管理的自动化脚本
- `version.sh`: 版本号管理脚本

## Makefile 使用

### 可配置的环境变量

- `IMAGE_NAME`: Docker 镜像名称

### 独立使用

#### 1. 使用默认镜像名

```bash
cd scripts
make image
```

#### 2. 使用自定义镜像名

```bash
cd scripts
IMAGE_NAME=myregistry/myimage make image
```

或者：

```bash
export IMAGE_NAME=myregistry/myimage
cd scripts
make image
```

### 在其他 Makefile 中引用

有多种方式可以在其他 Makefile 中引用这个 Makefile：

#### 方式一：使用 `$(MAKE) -C` 调用子目录（推荐）

在项目根目录创建主 Makefile：

```makefile
.PHONY: build-image

# 定义镜像名称
IMAGE_NAME = myregistry/myproject

# 调用 scripts 目录下的 Makefile
build-image:
	IMAGE_NAME=$(IMAGE_NAME) $(MAKE) -C scripts image

# 或者使用 export 导出环境变量
build-image-export:
	export IMAGE_NAME=$(IMAGE_NAME) && $(MAKE) -C scripts image
```

使用：

```bash
make build-image
```

#### 方式二：使用 `include` 包含

在项目根目录的 Makefile 中：

```makefile
# 设置变量（会覆盖被包含文件中的默认值）
IMAGE_NAME = myregistry/myproject

# 包含 scripts 目录的 Makefile
include scripts/Makefile

# 现在可以直接调用 image 目标
.PHONY: build
build: image
```

使用：

```bash
make build
```

**注意**: 使用 `include` 时，相对路径会基于主 Makefile 的位置，可能需要调整路径。

#### 方式三：环境变量传递（跨多层 Makefile）

根目录 `Makefile`:

```makefile
.PHONY: all

# 设置并导出环境变量，使所有子 make 都能访问
export IMAGE_NAME = myregistry/myproject
export VERSION = v1.0.0

all:
	@echo "Building with IMAGE_NAME=$(IMAGE_NAME)"
	$(MAKE) -C scripts image
```

#### 方式四：通过命令行传递多个变量

```bash
IMAGE_NAME=myregistry/myimage VERSION=v2.0.0 make -C scripts image
```

### 完整示例

假设项目结构：

```
/project-root
  ├── Makefile           # 主 Makefile
  ├── scripts/
  │   ├── Makefile       # 本文件
  │   └── version.sh
  └── ...
```

主 `Makefile` 内容示例：

```makefile
.PHONY: help build-backend build-frontend build-all

# 项目配置
PROJECT_NAME = myproject
REGISTRY = docker.io/myorg
BACKEND_IMAGE = $(REGISTRY)/$(PROJECT_NAME)-backend
FRONTEND_IMAGE = $(REGISTRY)/$(PROJECT_NAME)-frontend

help:
	@echo "Available targets:"
	@echo "  build-backend   - Build and push backend image"
	@echo "  build-frontend  - Build and push frontend image"
	@echo "  build-all       - Build and push all images"

build-backend:
	@echo "Building backend image..."
	IMAGE_NAME=$(BACKEND_IMAGE) $(MAKE) -C scripts image

build-frontend:
	@echo "Building frontend image..."
	IMAGE_NAME=$(FRONTEND_IMAGE) $(MAKE) -C scripts image

build-all: build-backend build-frontend
	@echo "All images built successfully!"

# 也可以创建版本管理的快捷方式
version:
	$(MAKE) -C scripts version $(filter-out $@,$(MAKECMDGOALS))

# 允许传递额外参数
%:
	@:
```

使用示例：

```bash
# 构建后端镜像
make build-backend

# 构建前端镜像
make build-frontend

# 构建所有镜像
make build-all

# 版本管理
make version patch
make version v1.2.3
```

## 版本管理

### 基本用法

```bash
# 查看当前版本和帮助
make version

# 设置特定版本
make version v1.0.0

# 或者
make version VERSION=v1.0.0

# 递增版本
make version patch   # v1.0.0 -> v1.0.1
make version minor   # v1.0.0 -> v1.1.0
make version major   # v1.0.0 -> v2.0.0

# 预发布版本
make version pre              # v1.0.0 -> v1.0.0-rc.1
make version pre alpha        # v1.0.0 -> v1.0.0-alpha.1
make version pre beta         # v1.0.0 -> v1.0.0-beta.1
make version pre rc 2         # v1.0.0 -> v1.0.0-rc.2
```

## 创建标签

```bash
# 基于 VERSION 文件创建并推送 Git 标签
make tag
```

## 注意事项

1. **环境变量优先级**:
   - 命令行传递 > 父 Makefile export > 本 Makefile 默认值

2. **工作目录**:
   - 使用 `$(MAKE) -C scripts` 会切换到 scripts 目录执行
   - 注意脚本中的相对路径问题

3. **变量传递**:
   - `IMAGE_NAME=xxx $(MAKE)`: 只对当前 make 有效
   - `export IMAGE_NAME=xxx; $(MAKE)`: 对所有子 make 有效
   - `export IMAGE_NAME=xxx` 后再调用: 对整个 shell 会话有效

4. **调试技巧**:
   ```bash
   # 查看实际使用的变量值
   make -C scripts image -n  # 干运行，只显示命令不执行
   ```

## 扩展建议

如果需要更复杂的配置，可以创建配置文件：

```makefile
# config.mk
PROJECT_NAME = myproject
REGISTRY = docker.io/myorg
VERSION = v1.0.0

# 在主 Makefile 中
include config.mk
export IMAGE_NAME = $(REGISTRY)/$(PROJECT_NAME)
```

这样可以将配置集中管理，便于维护。
