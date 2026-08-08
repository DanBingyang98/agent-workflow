---
name: to-questionnaire
description: 把你无法完全回答的决策变成给别人填的问卷。
disable-model-invocation: true
---

把用户无法独自回答的东西变成**问卷**——一份 Markdown 文档，交给一个人异步填，或在会议上一起填。接收者握有用户缺乏的知识；问卷把它从他们那里掏出来。

**拷问发送，不是主题。** 只访谈用户关于_发送_，这他们总能回答：发给谁，需要拿回什么。文档里的问题随后瞄准接收者所知与用户所需之间的**缺口**。

1. **发给谁？** 用一次交流问接收者的角色、专业领域、与用户的关系。这固定问卷的语气和它必须携带多少上下文。完成当你知道接收者是谁、以及他们知道什么用户不知道的。

2. **你需要拿回什么？** 用一次交流问用户独自无法解决、需要从这个人身上得到的具体决策或事实。完成当你有一份具体清单，列出用户必须带着走的能力或决定。

3. **写问卷。** 起草瞄准步骤 1–2 缺口的问题，遵循下面的文档结构。写到当前目录的 `to-questionnaire-<slug>.md`（slug 取自主题）并报告路径。完成当文件存在、且用户在第 2 步点名的每项都被一个问题覆盖。

## 文档结构

把文档框成**发现问卷（discovery questionnaire）**：用户缺上下文，接收者握着它。问题按最重要在前排序——异步意味着你可能只有一次机会——超过几个后按主题用 `##` 标题分组。用下面的模板写。

<questionnaire-template>

# <Questionnaire title>

**Purpose:** 为什么这份问卷存在、压在它上面的决策是什么。

**From:** <the user> — **To:** <the recipient> — **How your answers will be used:** <它们去哪里>

## Context

一段，让没在用户脑子里的接收者定向。足够答好即可，不是一页。

## How to answer

截止时间和大致工作量。部分回答和「我不知道」有用——对你不确定的东西标记出来，不要跳过。

## <Theme heading>

每个主题一个 `##` 部分。下面放它的问题，最重要在前。每个问题是一个想法——绝不复合——正下方有答案 stub，只在问题可能被误读或招来敷衍回答时加一行_为什么这重要_。

<question-example>
### What load is the system expected to handle at launch?

_Why this matters: it decides whether we provision for burst traffic now or defer it._

>
</question-example>

## Anything else?

收尾兜底：我们没问但你应该让我们知道的东西？

</questionnaire-template>
