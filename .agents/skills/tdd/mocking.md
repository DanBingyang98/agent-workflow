# 何时 mock

**只在系统边界** mock：

- 外部 API（支付、邮件等）
- 数据库（有时——更偏好测试 DB）
- 时间/随机性
- 文件系统（有时）

不要 mock：

- 自己的类/模块
- 内部协作者
- 任何你控制的东西

## 为可 mock 性设计

在系统边界，设计容易 mock 的接口：

**1. 用依赖注入**

把外部依赖传进来，而不是在内部创建：

```typescript
// Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. 偏好 SDK 风格接口，而不是通用 fetcher**

为每个外部操作创建具体函数，而不是一个带条件逻辑的通用函数：

```typescript
// GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK 方式意味着：

- 每个 mock 返回一个具体形态
- 测试设置里没有条件逻辑
- 更容易看出测试覆盖了哪些端点
- 每个端点有类型安全
