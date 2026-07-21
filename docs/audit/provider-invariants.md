# Provider Invariants — Pass 2

**Subsystem:** Provider System & Model Routing  
**Code root:** `sandbox-conduit (1)/` (`src/ApiRouter.ts`, `src/utils/generationSettings.ts`, `src/utils/appSettings.ts`, `src/utils/gatewaySettings.ts`, `server.ts` `/api/generate`, `server/tenant/managedCompile.ts`, related UI)  
**Pass:** 2 (Subsystem Audit)  
**Audit date:** 2026-07-21  
**Rule:** Evidence-backed from executable code only.

| Invariant | Why it matters | Evidence | Violation risk |
|-----------|----------------|----------|----------------|
| Power sources are exactly `BYOK` \| `WEBGPU` \| `P2P` \| `SANDBOX_HOSTED` | Controls where compile prompts may go | `PowerSource` in `appSettings.ts`; `getPowerSource()` | **Medium** — invalid stored values coerce to `BYOK` |
| `SANDBOX_HOSTED` is evaluated before gateway/BYOK in `getGenerationSettings` | Hosted path must not leak tenant BYOK keys into managed routing | Early return `provider: "sandbox-hosted"`, empty `apiKey` | **High** if order reversed |
| Managed hosted compile requires server env key + Clerk (or e2e mocks) + entitlement | Prevents unpaid/unconfigured hosted inference | `gateManagedCompile` in `managedCompile.ts` | **Medium** — trial flag / e2e mocks widen access |
| Hosted compile uses **server** keys only (`resolveManagedCompileApiKey`), not request BYOK | Tenant keys must not pay for hosted | `hostedCompile ? resolveManagedCompileApiKey() : resolveProviderApiKey(...)` in `server.ts` | **High** if body key preferred for hosted |
| All server LLM calls for generate go through OpenAI-compatible `fetchChatCompletion` | Single HTTP protocol surface | `ApiRouter.ts` + `/api/generate` race call | **Medium** — native Anthropic/Google SDKs not used; compat quirks |
| Endpoint URLs without `/chat/completions` append `/v1/chat/completions` | Normalizes LM Studio / Ollama / custom bases | `fetchChatCompletion` URL rewrite | **Medium** — wrong base path if provider already uses non-v1 paths |
| BYOK provider string selects endpoint: google → Gemini OpenAI-compat; openai → api.openai.com; anthropic → OpenRouter default | Maps UI provider to HTTP target | `server.ts` activeProvider branches | **High** — Anthropic default is OpenRouter, not api.anthropic.com |
| `provider === "gateway"` (or body gateway fields) routes to `localEndpointUrl` or LM Studio default `127.0.0.1:1234/v1` | Local/custom gateway support | gateway branch in `/api/generate` | **Medium** — SSRF risk if untrusted URL accepted without checks (Unknown in this pass for generate path) |
| Enabling gateway (`isGatewayEnabled()`) forces `getGenerationSettings().provider` to `"gateway"` even when power is `BYOK` | Gateway flag overrides BYOK provider selection | `if (powerSource === "WEBGPU" \|\| isGatewayEnabled())` | **High** — surprising routing vs UI “BYOK” label |
| `P2P` power source never allows generation (`canGenerate` returns false) | Preview stub must not pretend to work | `canGenerate` P2P branches | **Low** |
| Client compile tries offline templates / sovereign-local / labs browser-LLM before `/api/generate` | Privacy / offline path preference | `runClientCompile` then `TheSand.executeCompile` | **Medium** — WEBGPU without engine blocks rather than always falling back |
| Persistence of routing prefs is primarily `localStorage` keys (`sandbox_power_source`, `sc_provider`, `sc_model`, provider keys, `sc_gateway_settings`) | Settings survive reload | `appSettings` / `gatewaySettings` / `generationSettings` | **High** — keys in plaintext localStorage |
| API key resolution order for BYOK: request body → tenant vault → process env | Lets UI key win, then vault, then server env | `resolveProviderApiKey` | **Medium** — env fallback can surprise multi-tenant ops |
| Compile generate is async Node with timeout race | Bounds hung provider calls | `Promise.race` + `COMPILE_TIMEOUT_MS` | **Low** |
| UI lists four power sources including P2P stub and gated Sandbox Hosted | Product surface matches type union | `GeneralRoutingPanel` `powerSources` | **Low** |

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
    - ../sandbox-conduit (1)/src/utils/appSettings.ts
    - ../sandbox-conduit (1)/src/utils/gatewaySettings.ts
    - ../sandbox-conduit (1)/src/utils/browserCompile.ts
    - ../sandbox-conduit (1)/src/components/TheSand.tsx
    - ../sandbox-conduit (1)/src/components/settings/GeneralRoutingPanel.tsx
    - ../sandbox-conduit (1)/server.ts
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
    - ../sandbox-conduit (1)/server/tenant/keyVault.ts
  symbols:
    - fetchChatCompletion
    - getGenerationSettings
    - getPowerSource
    - canGenerate
    - gateManagedCompile
    - isSandboxHostedCompileRequest
    - resolveProviderApiKey
    - runClientCompile
    - executeCompile
    - gatewayGeneratePayload
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/cloudDriveProviders.ts
    - ../sandbox-conduit (1)/src/contexts/AppProviders.tsx
    - ../sandbox-os-core/shell/launcher-server.mjs
```

## Halt

Pass 2 invariants for Provider System & Model Routing complete.
