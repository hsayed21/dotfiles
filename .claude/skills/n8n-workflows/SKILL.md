---
name: n8n-workflows
description: n8n workflow automation patterns — AI agent design, custom code nodes, MCP integration, webhooks, error handling, and production deployment.
---

# n8n Workflow Automation

Patterns for building reliable, maintainable n8n workflows, with focus on AI-powered customer support agents.

## When to Activate

- Designing n8n workflows (AI agents, data pipelines, integrations)
- Writing custom code nodes (JavaScript)
- Integrating n8n MCP with external systems
- Debugging workflow failures
- Optimizing workflow performance
- Setting up webhook triggers and HTTP endpoints

## AI Agent Workflow Pattern

### Customer Support Agent Architecture

```
[Webhook/Chat Trigger]
    ↓
[Switch: Intent Detection]
    ├─→ "order_status"   → [HTTP: Fetch Order API]    → [AI: Generate Response] → [Reply]
    ├─→ "product_search" → [HTTP: Search Products]    → [AI: Generate Response] → [Reply]
    ├─→ "complaint"      → [Create Ticket]            → [AI: Escalate Response] → [Reply]
    └─→ "fallback"       → [AI: General Response]     → [Reply]
```

### Intent Detection Node (AI)

```javascript
// Custom Code Node: Parse intent from user message
const message = $input.first().json.message;
const intents = [
  { name: 'order_status', keywords: ['order', 'status', 'tracking', 'delivery', 'where is'] },
  { name: 'product_search', keywords: ['find', 'search', 'product', 'price', 'buy'] },
  { name: 'complaint', keywords: ['complaint', 'refund', 'broken', 'wrong', 'angry', 'bad'] },
  { name: 'account', keywords: ['login', 'password', 'account', 'profile', 'email'] }
];

const matched = intents.find(i => i.keywords.some(k => message.toLowerCase().includes(k)));

return {
  intent: matched?.name ?? 'general',
  confidence: matched ? 'high' : 'low',
  originalMessage: message
};
```

## Custom Code Node Patterns

### Safe API Call Wrapper

```javascript
// Always wrap external API calls with error handling
async function safeApiCall(url, options = {}) {
  try {
    const response = await $http.get(url, options);
    return { success: true, data: response };
  } catch (error) {
    console.error(`API call failed: ${url}`, error.message);
    return { success: false, error: error.message };
  }
}

const result = await safeApiCall('https://api.example.com/orders', {
  headers: { Authorization: `Bearer ${$env.API_KEY}` }
});

return { json: result };
```

### Data Transformation

```javascript
// Transform and validate API responses before passing downstream
const orders = $input.all().map(item => {
  const o = item.json;
  return {
    id: o.id,
    customer: o.customer_name ?? 'Unknown',
    status: o.status?.toLowerCase() ?? 'unknown',
    total: Number(o.total_amount) || 0,
    items: Array.isArray(o.items) ? o.items.length : 0,
    createdAt: new Date(o.created_at).toISOString()
  };
});

// Filter out invalid records
const valid = orders.filter(o => o.id && o.customer !== 'Unknown');

return valid.map(o => ({ json: o }));
```

### Rate Limiting / Batching

```javascript
// Process items in batches with delays
const BATCH_SIZE = 5;
const DELAY_MS = 1000;
const items = $input.all();
const results = [];

for (let i = 0; i < items.length; i += BATCH_SIZE) {
  const batch = items.slice(i, i + BATCH_SIZE);
  const batchResults = await Promise.all(
    batch.map(item => processItem(item.json))
  );
  results.push(...batchResults);

  if (i + BATCH_SIZE < items.length) {
    await new Promise(resolve => setTimeout(resolve, DELAY_MS));
  }
}

return results.map(r => ({ json: r }));
```

## Webhook Patterns

### Secure Webhook Validation

```javascript
// Validate incoming webhook signature
const crypto = require('crypto');

const payload = JSON.stringify($input.first().json);
const signature = $input.first().headers['x-webhook-signature'];
const expected = crypto
  .createHmac('sha256', $env.WEBHOOK_SECRET)
  .update(payload)
  .digest('hex');

if (signature !== expected) {
  throw new Error('Invalid webhook signature');
}

return { json: { validated: true, data: $input.first().json } };
```

### Deduplication

```javascript
// Prevent processing duplicate webhook events
const eventId = $input.first().json.idempotency_key ?? $input.first().json.event_id;

// Check if already processed (use Redis or DB node)
const existing = await $redis.get(`event:${eventId}`);
if (existing) {
  return { json: { skipped: true, reason: 'duplicate', eventId } };
}

await $redis.set(`event:${eventId}`, 'processed', 'EX', 3600);
return { json: { processed: true, eventId, data: $input.first().json } };
```

## Error Handling

### Workflow-Level Error Handling

```
[Main Workflow]
    ↓ (On Error)
[Error Handler Branch]
    → [Log to Discord/Slack/Email]
    → [Save failed item to DB for retry]
    → [Continue / Stop based on severity]
```

### Error Notification Node

```javascript
// Send structured error alert
const error = $input.first().json;
const alert = {
  workflow: $workflow.name,
  node: $node.name,
  timestamp: new Date().toISOString(),
  error: error.message ?? JSON.stringify(error),
  inputData: JSON.stringify($input.first().json).slice(0, 500)
};

// Log and notify
console.error('Workflow Error:', alert);
return { json: alert };
```

## MCP Integration Pattern

When using the n8n MCP server to trigger or manage workflows:

```
[Claude / External System]
    ↓ (n8n MCP call)
[n8n Webhook Trigger]
    ↓
[Workflow executes]
    ↓
[Response back via Webhook Response Node]
    ↓
[MCP returns result to caller]
```

```javascript
// Webhook response node: format result for MCP consumer
const result = $input.first().json;

return {
  json: {
    success: true,
    workflowName: $workflow.name,
    executionId: $execution.id,
    result: result,
    timestamp: new Date().toISOString()
  }
};
```

## Workflow Design Principles

1. **Single responsibility** — Each workflow does one thing well
2. **Error branches** — Every workflow has error handling paths
3. **Idempotency** — Webhook handlers deduplicate events
4. **Logging** — Key steps log structured data for debugging
5. **Secrets in env** — Never hardcode API keys in code nodes
6. **Test mode first** — Use n8n's test mode before activating
7. **Version control** — Export and commit workflow JSON to git

## Performance Tips

- Use **batch processing** for >100 items (not sequential HTTP requests)
- Set **timeouts** on HTTP Request nodes (default 5s, increase for slow APIs)
- Use **Switch node** for routing instead of multiple IF nodes
- **Cache** frequently used data with Redis/memory nodes
- Disable **"Execute Node" logging** in production for faster execution
