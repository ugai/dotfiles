# GitHub Labels

## Commonly Used

### priority

| Name | Description | Color |
|------|-------------|-------|
| `priority:p0` | Critical - requires immediate action | `#D32F2F` |
| `priority:p1` | High - should be addressed soon | `#F57C00` |
| `priority:p2` | Normal - default priority | `#FFB366` |
| `priority:p3` | Low - when time permits | `#A7E08E` |

<span style="background:#D32F2F;color:#fff;border-radius:2em;padding:2px 9px;font-size:12px">priority:p0</span> <span style="background:#F57C00;color:#fff;border-radius:2em;padding:2px 9px;font-size:12px">priority:p1</span> <span style="background:#FFB366;color:#333;border-radius:2em;padding:2px 9px;font-size:12px">priority:p2</span> <span style="background:#A7E08E;color:#333;border-radius:2em;padding:2px 9px;font-size:12px">priority:p3</span>

### agent

| Name | Description | Color |
|------|-------------|-------|
| `agent:proposed` | Proposed by an AI agent | `#A78BFA` |
| `agent:ready` | Approved for autonomous agent pickup | `#7C3AED` |

<span style="background:#A78BFA;color:#fff;border-radius:2em;padding:2px 9px;font-size:12px">agent:proposed</span> <span style="background:#7C3AED;color:#fff;border-radius:2em;padding:2px 9px;font-size:12px">agent:ready</span>

### misc

| Name | Description | Color |
|------|-------------|-------|
| `pending` | On hold / deferred | `#cfd3d7` |

<span style="background:#cfd3d7;color:#333;border-radius:2em;padding:2px 9px;font-size:12px">pending</span>

## Design Notes

### Color System

**Severity scale** (ordered labels like `priority:*`)

Hue shifts red → orange → yellow-green along the traffic-light convention.

| Severity | Hue | Lightness | Text | Visual intent |
|----------|-----|-----------|------|---------------|
| High | Red–Orange (0°–30°) | ≈50% (dark) | white | draw attention |
| Low | Yellow-green (≈102°) | ≈70% (light) | dark | recede |

> [!NOTE]
> The `priority:*` colors are inspired by [QwenLM/qwen-code](https://github.com/QwenLM/qwen-code/labels?q=priority). p0/p1 exactly match Material Design (Red 700 / Orange 700); p2/p3 are close but not exact, possibly from a derived design system.

> [!TIP]
> Traditional plotting colormaps (e.g. matplotlib's RdYlGn, Spectral) follow the same red-to-green hue shift but pass through yellow rather than orange, and are optimized for continuous data — less suitable for a few discrete labels.

**Categorical scale** (grouped labels like `agent:*`)

Hue is fixed within the group; only lightness varies. Makes the group instantly recognizable as one category.

| Role | Hue | Lightness |
|------|-----|-----------|
| Proposed / tentative | ≈258° (purple), light | ≈76% |
| Confirmed / active | ≈258° (purple), dark | ≈58% |
