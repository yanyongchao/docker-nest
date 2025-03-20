# 1. 使用 Node.js 镜像作为构建阶段
FROM node:lts AS build-stage

# 安装 pnpm 包管理工具
RUN npm install -g pnpm

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 pnpm 配置文件
COPY package*.json pnpm*.yaml ./

# 设置 npm 镜像源为国内源
RUN npm config set registry https://registry.npmmirror.com/

# 使用 pnpm 安装所有依赖（包括开发和生产依赖）
RUN pnpm install

# 复制项目文件到容器
COPY . .

# 执行构建命令
RUN pnpm build

# 2. 使用 Node.js 镜像作为生产环境的基础镜像
FROM node:lts AS production-stage

# 复制构建阶段的构建输出和 package.json 到生产镜像
COPY --from=build-stage /app/dist /app/dist
COPY --from=build-stage /app/package.json /app/package.json
COPY --from=build-stage /app/node_modules /app/node_modules

# 设置工作目录
WORKDIR /app

# 暴露应用运行的端口（假设你的应用使用的是 3000）
EXPOSE 3000

# 启动应用
CMD [ "node", "/app/dist/main.js" ]
