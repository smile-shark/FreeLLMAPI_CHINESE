# AGENTS 指南

- **开发环境**
  - `npm run dev` – 并行启动服务器 (`server/src/index.ts`) 与仪表盘 (`client/vite`).
  - `npm run dev:lan` – 同上，但把 Vite UI 暴露到局域网；注意 `--host` 必须通过包装脚本传递，直接 `npm run dev -- --host` 无效。
  - 单独启动服务或 UI：`npm run dev -w server` / `npm run dev -w client`（workspace `-w` 选项）。

- **构建 & 生产**
  - `npm run build` – 编译 server (`tsc`) 与 client (`vite build`).
  - 生产启动：`node server/dist/index.js`（默认端口 3001）。

- **测试**
  - `npm test` – 运行 `server` 的 Vitest 测试，然后（若存在）`client` 测试。
  - 单独运行 server 测试：`npm run test -w server`。
  - 监视模式：`npm run test:watch`（在 server 工作区）。

- **Docker**
  - 生成 `.env`（必填 `ENCRYPTION_KEY`）后 `docker compose up -d` 启动 API 与仪表盘。
  - 默认只在 `127.0.0.1:3001` 公开；若要局域网访问，设置 `HOST_BIND=0.0.0.0` 环境变量。
  - 数据持久化在 Docker 卷 `freellmapi-data` → `/app/server/data`。

- **环境变量关键点** (`.env.example`)
  - `ENCRYPTION_KEY` – 用 `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` 生成。
  - `PORT` – 服务器端口，默认 3001。
  - `PROXY_RATE_LIMIT_RPM` – 每分钟最大请求数，默认 120，设 `0` 禁用。
  - `REQUEST_ANALYTICS_RETENTION_DAYS` / `REQUEST_ANALYTICS_MAX_ROWS` – 分别控制保留天数与行数，设 `0` 关闭对应限制。
  - `HOST_BIND` – Docker 仅用，控制容器端口绑定接口。

- **单模型健康检查脚本**
  - 从 `server` 工作区运行 `npx tsx src/scripts/test-all-models.ts` 检查所有已启用模型是否可达。
  - 脚本会为每个模型发起最小化 `chatCompletion`（`max_tokens:5`，超时 120 s）并输出成功/失败统计。

- **新增 Provider**
  - 复制 `server/src/providers/openai-compat.ts` 为模板，添加到 `server/src/providers/index.ts` 并在 `server/src/db/index.ts` 的种子文件中注册模型。
  - 必须为每个新模型编写对应测试文件于 `server/src/__tests__/providers/`。

- **工作区结构**
  - `shared/` – 共享类型 (`types.ts`) 与 npm 包 (`package.json`).
  - `server/` – Express API、路由、提供者、数据库迁移与测试。
  - `client/` – React + Vite 仪表盘。默认 `npm run dev` 同时启动。

- **代理配置**：若部分 Provider（如 Google）因网络限制无法直连，在 `.env` 设置 `HTTP_PROXY=http://127.0.0.1:7897`、`HTTPS_PROXY=http://127.0.0.1:7897` 及 `NO_PROXY` 排除国内可达的域名。`server/src/proxy.ts` 使用 undici 的 `EnvHttpProxyAgent` 自动读取这些环境变量。
  - 注意：`global-agent` 无效，因为它修补 `http.globalAgent`，但 Node.js 内置 `fetch()`（基于 undici）不使用它。
  - 启动日志出现 `[proxy] Enabled (http://127.0.0.1:7897)` 表示代理已生效。
- **常见陷阱**
  - **Vite LAN**：`npm run dev:lan` 已内置 `--host`，手动追加 `--host` 会被 `concurrently` 包裹的脚本忽略。
  - **Docker 绑定**：未显式设置 `HOST_BIND` 时容器只能本机访问；暴露到 LAN 前务必确认网络受信任。
  - **加密密钥丢失**：`ENCRYPTION_KEY` 存于 `.env`，在容器升级或本地恢复时必须保留相同值，否则已存储的提供商密钥不可解密。
