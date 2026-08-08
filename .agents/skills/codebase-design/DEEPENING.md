# Deepening（加深）

如何在给定依赖的情况下安全地加深一组浅模块。假设 [SKILL.md](SKILL.md) 中的词汇——**module**、**interface**、**seam**、**adapter**。

## 依赖分类

评估加深候选时，给它的依赖分类。类别决定加深后的模块如何在接缝上被测试。

### 1. 进程内（In-process）

纯计算、内存状态、无 I/O。总是可加深——合并模块，直接通过新接口测试。无需 adapter。

### 2. 本地可替身（Local-substitutable）

有本地测试替身的依赖（Postgres 用 PGLite、内存文件系统）。替身存在就可加深。加深后的模块用跑在测试套件里的替身测试。接缝是内部的；模块外部接口处没有 port。

### 3. 远程但自有（Ports & Adapters）

跨网络边界的你自己的服务（微服务、内部 API）。在接缝处定义 **port**（接口）。深模块拥有逻辑；传输以 **adapter** 注入。测试用内存 adapter。生产用 HTTP/gRPC/queue adapter。

建议形态：*"Define a port at the seam, implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."*

### 4. 真正外部（Mock）

你不控制的第三方服务（Stripe、Twilio 等）。加深后的模块把外部依赖作为注入的 port 接收；测试提供 mock adapter。

## 接缝纪律

- **一个 adapter 意味着假设性接缝；两个意味着真实接缝。** 除非至少两个 adapter 站得住（通常生产 + 测试），否则不要引入 port。单 adapter 接缝只是间接层。
- **内部接缝 vs 外部接缝。** 深模块可以有内部接缝（实现私有、供自己的测试用）以及接口处的外部接缝。不要因为测试在用就把内部接缝通过接口暴露出去。

## 测试策略：替换，不要分层

- 加深后模块的接口测试一存在，浅模块上的旧单元测试就是浪费——删掉它们。
- 在加深后模块的接口处写新测试。**接口就是测试面。**
- 测试通过接口断言可观察结果，不是内部状态。
- 测试应能挺过内部重构——它们描述行为，不是实现。如果实现变了测试就得变，那是在测接口里面。
