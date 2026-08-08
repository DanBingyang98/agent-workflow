# HTML 报告格式

架构审查渲染为 OS 临时目录中的单个自包含 HTML 文件。Tailwind 和 Mermaid 都来自 CDN。Mermaid 可靠处理图状图形；手工 div 和内联 SVG 处理更编辑风格的视觉（质量图、截面）。两者混用——不要什么都靠 Mermaid，它会开始显得千篇一律。

## 脚手架

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review — {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* Tailwind 覆盖不干净的小自定义层：
         虚线接缝线、手绘感箭头等 */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## 页头

仓库名、日期和紧凑图例：实心框 = 模块、虚线 = 接缝、红箭头 = 泄漏、粗深色框 = 深模块。没有引言段落——直接进候选。

## 候选卡片

图形承担主要重量。散文稀疏、平实，使用词汇表术语（来自 `/codebase-design` 技能），不铺陈。

每个候选是一个 `<article>`：

- **Title** —— 短，命名加深（例如「Collapse the Order intake pipeline」）。
- **Badge row** —— 建议强度（`Strong` = emerald、`Worth exploring` = amber、`Speculative` = slate），加依赖类别标签（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）。
- **Files** —— 等宽字体列表，`font-mono text-sm`。
- **Before / After diagram** —— 核心。两列并排。见下面各模式。
- **Problem** —— 一句。哪里疼。
- **Solution** —— 一句。什么变了。
- **Wins** —— 要点，每个 ≤6 词。例如「Tests hit one interface」、「Pricing logic stops leaking」、「Delete 4 shallow wrappers」。
- **ADR callout**（如适用）—— amber 色调框里一行。

不要解释性段落。如果图形需要一段话才能看懂，重画图形。

## 图形模式

挑适合候选的模式。混用。不要让每张图都一样——变化本身就是重点。

### Mermaid graph（依赖 / 调用流的万金油）

当要点是「X calls Y calls Z，看这团乱麻」时用 Mermaid `flowchart` 或 `graph`。包在 Tailwind 风格卡片里，别像空降的。用 classDef 把泄漏边染红、深模块染深。序列图适合「before: 6 round-trips; after: 1」。

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### 手工 boxes-and-arrows（当 Mermaid 的布局与你作对时）

模块用带边框和标签的 `<div>`。箭头用绝对定位在 relative 容器上的内联 SVG `<line>` 或 `<path>`。当你想让「after」图感觉像一个粗边框深模块、内部灰化时用它——Mermaid 渲染不出那种重量感。

### 截面（适合分层浅度）

堆叠水平条（`h-12 border-l-4`）展示一次调用穿过的层。Before：6 条什么都不做的薄层。After：1 条标着整合后职责的粗带。

### 质量图（适合「接口和实现一样宽」）

每个模块两个矩形——一个接口表面积、一个实现。Before：接口矩形几乎和实现矩形一样高（浅）。After：接口矩形矮、实现矩形高（深）。

### 调用图折叠

Before：函数调用树渲染成嵌套框。After：同一棵树折叠进一个框，现在内部的调用在其中淡显。

## 样式指导

- 编辑风格，不是公司 dashboard。充足留白。标题可选衬线（`font-serif` 与 stone/slate 配得很好）。
- 节制用色：一个强调色（emerald 或 indigo）加泄漏红和警告 amber。
- 图形保持约 320px 高，让 before/after 舒适并排、无需滚动。
- 图形内模块标签用 `text-xs uppercase tracking-wider`——它们应读作示意图，不是 UI。
- 唯一脚本是 Tailwind CDN 和 Mermaid ESM import。报告其余静态——没有应用代码，除 Mermaid 自身渲染外无交互。

## 首选建议部分

一张更大的卡片。候选名、一句为什么、锚点链接到它的卡片。就这些。

## 语气

平实简洁——但架构名词和动词直接来自 `/codebase-design` 技能。简洁不是漂移的借口。

**严格使用：** module、interface、implementation、depth、deep、shallow、seam、adapter、leverage、locality。

**绝不替换：** component、service、unit（代替 module）· API、signature（代替 interface）· boundary（代替 seam）· layer、wrapper（指 module 时）。

**合风格的措辞：**

- "Order intake module is shallow — interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

**Wins 要点**用词汇表术语命名收益：*"locality: bugs concentrate in one module"*、*"leverage: one interface, N call sites"*、*"interface shrinks; implementation absorbs the wrappers"*。不要写 *"easier to maintain"* 或 *"cleaner code"*——那些词不在词汇表里，也不配占位。

不要含糊其辞、不要清嗓子、不要「it's worth noting that…」。句子能变成要点就变要点。要点能砍就砍。术语不在 `/codebase-design` 词汇表里，就先用里面有的，别发明新的。
