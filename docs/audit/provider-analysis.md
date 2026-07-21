# Provider Analysis — Pass 2

**Subsystem:** Provider System & Model Routing  
**Code root:** `sandbox-conduit (1)/` (Builder / Sand compile inference routing)  
**Pass:** 2 (Subsystem Audit)  
**Audit date:** 2026-07-21  
**Constraint:** Claims grounded in code. Confidence: High / Medium / Low / Unknown.  
**Note:** This subsystem does **not** live in `sandbox-os` or `sandbox-os-core`. Artifacts are filed under the OS audit series for continuity.

---

## Interfaces

### Client settings / routing selectors

| Aspect | Interface |
|--------|-----------|
| **Inputs** | `localStorage` power source, provider, model, API keys, gateway JSON; UI props (`activePowerSource`, keys); billing/Clerk for hosted gate |
| **Outputs** | `GenerationSettings { provider, model, apiKey }`; `GenerationGate`; `CompilePrivacyMode` labels |
| **State changes** | Writes settings keys via `savePowerSource` / `saveModel` / `saveGatewaySettings` / key fields |
| **External dependencies** | Browser `localStorage`; optional Clerk/billing HTTP |
| **Called by** | `TheSand.executeCompile`, Settings panels, `App.tsx` generation paths |
| **Calls into** | `getPowerSource`, gateway helpers, managed compile gate |
| **Persistence** | Browser localStorage (and optional server settings sync elsewhere — not fully audited here) |
| **Threading/async** | Sync reads; async only when probing/billing |

### Agnostic HTTP router — `src/ApiRouter.ts`

| Aspect | Interface |
|--------|-----------|
| **Inputs** | `ChatCompletionPayload` (endpoint, key, auth scheme, model, prompts, temp, maxTokens) |
| **Outputs** | Assistant message string from `choices[0].message.content` |
| **State changes** | None |
| **External dependencies** | Remote OpenAI-compatible HTTP APIs via `fetch` |
| **Called by** | `server.ts` generate/shore paths; `sovereignAgentRunner`; `oceanBriefSynthesis`; `sovereignStationRouter` |
| **Calls into** | Provider HTTP endpoints |
| **Persistence** | None |
| **Threading/async** | `async fetchChatCompletion` |

### Server generate route — `POST /api/generate` \| `/api/sandbox/generate`

| Aspect | Interface |
|--------|-----------|
| **Inputs** | JSON body: `prompt`, `provider`, `powerSource`, `apiKey`, `model`, gateway fields, VFS flags, etc.; tenant from auth middleware |
| **Outputs** | JSON success/files/preview or error status (401/403/503/429/400) |
| **State changes** | Writes project files under tenant sandbox dir; increments compile counters |
| **External dependencies** | Managed env keys; vault; upstream LLM HTTP; quota middleware |
| **Called by** | Client `sandboxFetch` after client-compile miss |
| **Calls into** | `gateManagedCompile`, `resolveProviderApiKey` / managed key resolvers, `fetchChatCompletion` |
| **Persistence** | Generated project files + tenant compile metrics |
| **Threading/async** | Express async handler; `Promise.race` timeout |

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
    - ../sandbox-conduit (1)/src/ApiRouter.ts
    - ../sandbox-conduit (1)/server.ts
    - ../sandbox-conduit (1)/src/components/TheSand.tsx
  symbols:
    - getGenerationSettings
    - fetchChatCompletion
    - executeCompile
    - gateManagedCompile
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/cloudDriveProviders.ts
```

---

## Verified Facts

### 1. Power source type is a closed set of four strings

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/appSettings.ts
  symbols:
    - PowerSource
    - getPowerSource
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
```

### 2. `getGenerationSettings` maps `SANDBOX_HOSTED` → provider `sandbox-hosted` with empty apiKey

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
  symbols:
    - getGenerationSettings
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
```

### 3. If power is `WEBGPU` **or** gateway is enabled, settings provider becomes `gateway`

Uses gateway model name and gateway API key.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
    - ../sandbox-conduit (1)/src/utils/gatewaySettings.ts
  symbols:
    - getGenerationSettings
    - isGatewayEnabled
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/utils/managedCompileGate.ts
```

### 4. Otherwise BYOK uses `sc_provider` (default `google`) and `sc_<provider>_key` or `sandbox_neural_key`

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
  symbols:
    - PROVIDER_KEY_MAP
    - getGenerationSettings
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
```

### 5. `fetchChatCompletion` posts OpenAI-style chat messages and returns one content string

Appends `/v1/chat/completions` when missing; supports bearer or `x-api-key`.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
  symbols:
    - fetchChatCompletion
    - applyAuthHeaders
    - ChatCompletionPayload
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
```

### 6. `/api/generate` runs `checkCompileQuota`, `gateManagedCompile`, then `rateLimitGenerate` before routing

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/server.ts
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
  symbols:
    - gateManagedCompile
    - isSandboxHostedCompileRequest
  confidence: High
  evidence_type:
    - api
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
```

### 7. Hosted compile detection uses body `provider === "sandbox-hosted"` or `powerSource === "SANDBOX_HOSTED"`

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
  symbols:
    - isSandboxHostedCompileRequest
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
```

### 8. Hosted path selects managed model/env key; non-hosted selects provider endpoint and `resolveProviderApiKey`

Google default endpoint `generativelanguage.googleapis.com/v1beta/openai`; OpenAI `api.openai.com`; Anthropic defaults to `api.openrouter.ai/v1` unless `localEndpointUrl` set; `local` and `gateway` use localhost defaults.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/server.ts
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
    - ../sandbox-conduit (1)/server/tenant/keyVault.ts
  symbols:
    - resolveManagedCompileApiKey
    - resolveManagedCompileModel
    - resolveProviderApiKey
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/components/settings/GeneralRoutingPanel.tsx
```

### 9. `resolveProviderApiKey` prefers body key, then vault decrypt, then env (`GEMINI_API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`/`OPENROUTER_API_KEY`)

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/server/tenant/keyVault.ts
  symbols:
    - resolveProviderApiKey
    - getVaultKey
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
```

### 10. `TheSand.executeCompile` gates with `canGenerate`, may `ensureBundledGatewayForCompile` for WEBGPU, tries `runClientCompile`, then POSTs `/api/generate` with provider/powerSource/apiKey/model and optional `gatewayGeneratePayload()`

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/components/TheSand.tsx
    - ../sandbox-conduit (1)/src/utils/browserCompile.ts
    - ../sandbox-conduit (1)/src/utils/gatewayClient.ts
  symbols:
    - executeCompile
    - runClientCompile
    - gatewayGeneratePayload
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
```

### 11. `runClientCompile` can succeed offline via templates; for WEBGPU either signals server fallback via gateway or hard-fails without engine; Labs may use browser WebGPU LLM

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/browserCompile.ts
  symbols:
    - runClientCompile
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/server.ts
```

### 12. `canGenerate` always denies usable P2P inference (missing node or preview-only)

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/appSettings.ts
  symbols:
    - canGenerate
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
```

### 13. `GeneralRoutingPanel` exposes Sandbox Hosted, BYOK, Sovereign local (WEBGPU), P2P stub

Hosted selection gated by `canSelectManagedCompile`.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/components/settings/GeneralRoutingPanel.tsx
    - ../sandbox-conduit (1)/src/utils/managedCompileGate.ts
  symbols:
    - GeneralRoutingPanel
    - canSelectManagedCompile
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
```

### 14. Gateway presets include lm-studio, ollama, open-router, custom with default base URLs

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/gatewaySettings.ts
  symbols:
    - GATEWAY_PRESETS
    - GatewaySettings
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
```

### 15. Bundled sovereign inference is expected on `127.0.0.1:11435/v1` and marked ready via localStorage flag

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/sovereignLocalInference.ts
  symbols:
    - BUNDLED_INFERENCE_PORT
    - applyBundledGatewaySettings
    - isBundledInferenceReady
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
```

### 16. Shore generation separately tries gateway then vault providers google→openai→anthropic via same `fetchChatCompletion`

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/server.ts
  symbols:
    - tryShoreLlmGenerate
    - fetchChatCompletion
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/components/TheSand.tsx
```

### 17. Default models differ between client defaults (`gemini-2.0-flash`) and server fallback when model omitted (`gemini-3.5-flash` on generate path)

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
    - ../sandbox-conduit (1)/server.ts
  symbols:
    - getGenerationSettings
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/utils/gatewaySettings.ts
```

### 18. `cloudDriveProviders.ts` / React `AppProviders` are not the LLM provider router

Different “provider” concepts (OAuth drives / React context).

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/cloudDriveProviders.ts
    - ../sandbox-conduit (1)/src/contexts/AppProviders.tsx
  symbols: []
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
```

### 19. Confidence Unknown: whether generate path applies SSRF protections to `localEndpointUrl`

`ssrf.ts` exists in tenant server; this pass did not prove it wraps `/api/generate` gateway URLs.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/server/tenant/ssrf.ts
    - ../sandbox-conduit (1)/server.ts
  symbols: []
  confidence: Unknown
  evidence_type:
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/server.ts
```

---

## Architectural Interpretation

### A. Routing is a two-layer decision: power source (policy) then provider endpoint (transport)

Power source chooses hosted vs local vs BYOK vs stub; provider/gateway choose HTTP target. Client computes settings; server re-derives endpoints and keys.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
    - ../sandbox-conduit (1)/server.ts
    - ../sandbox-conduit (1)/src/components/TheSand.tsx
  symbols:
    - getGenerationSettings
    - executeCompile
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/cloudDriveProviders.ts
```

### B. “Agnostic API Router” is intentionally SDK-free OpenAI-compat

All major providers are reached through one chat-completions shape, including Gemini’s OpenAI-compat URL and Anthropic-via-OpenRouter.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
    - ../sandbox-conduit (1)/server.ts
  symbols:
    - fetchChatCompletion
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/utils/browserLlm.ts
```

### C. WEBGPU power source is a product name for sovereign-local / gateway, not necessarily browser WebGPU compile

Bundled engine + gateway payload; Labs browser-LLM is separate behind `isLabsEnabled()`.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/browserCompile.ts
    - ../sandbox-conduit (1)/src/utils/sovereignLocalInference.ts
    - ../sandbox-conduit (1)/src/components/settings/GeneralRoutingPanel.tsx
  symbols:
    - runClientCompile
    - ensureBundledGatewayForCompile
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
```

### D. Gateway-enabled flag can shadow BYOK provider selection

Architectural coupling: global gateway enablement changes `getGenerationSettings` for non-hosted powers.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
  symbols:
    - getGenerationSettings
    - isGatewayEnabled
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/utils/managedCompileGate.ts
```

### E. Managed compile is a commercial gate around the same `fetchChatCompletion` transport

Entitlements/Clerk/env configuration wrap the hosted provider identity, not a separate model protocol.

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
    - ../sandbox-conduit (1)/server.ts
  symbols:
    - gateManagedCompile
    - resolveManagedCompileApiKey
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
```

---

## Engineering Assessment

### Strengths

1. **Single transport abstraction** (`fetchChatCompletion`) keeps provider adds mostly configuration. Confidence: **High**.  
2. **Hosted vs BYOK key separation** is explicit in generate routing. Confidence: **High**.  
3. **Client-first offline/sovereign attempts** before server LLM. Confidence: **High**.  
4. **Clear stubs** for P2P (denied) and gated hosted in UI. Confidence: **High**.

### Weaknesses / risks

1. **Gateway enable overrides BYOK** in `getGenerationSettings` — easy operator confusion. Confidence: **High**.  
2. **Anthropic labeled path defaults to OpenRouter** — not native Anthropic API. Confidence: **High**.  
3. **Plaintext API keys in localStorage** (`sc_*_key`). Confidence: **High**.  
4. **Default model string mismatch** client vs server fallbacks. Confidence: **High**.  
5. **P2P UI exists while generation is hard-blocked** — product honesty depends on badges. Confidence: **High**.  
6. **SSRF posture for custom gateway URLs on generate** — **Unknown** without proving middleware binding.  
7. **Naming debt:** `WEBGPU` power source ≠ primary WebGPU compile path. Confidence: **High**.

### Assessment summary

Provider System & Model Routing in Conduit is a **working multi-path inference router**: power-source policy, OpenAI-compatible HTTP transport, managed-hosted gating, BYOK/vault/env key resolution, and local gateway presets. It is **production-capable for BYOK/gateway/hosted**, with **stub P2P**, **localStorage key risk**, and **several routing footguns** (gateway overriding BYOK; Anthropic→OpenRouter; WEBGPU naming).

```yaml
evidence:
  files:
    - ../sandbox-conduit (1)/src/ApiRouter.ts
    - ../sandbox-conduit (1)/src/utils/generationSettings.ts
    - ../sandbox-conduit (1)/src/utils/appSettings.ts
    - ../sandbox-conduit (1)/server.ts
    - ../sandbox-conduit (1)/server/tenant/managedCompile.ts
    - ../sandbox-conduit (1)/server/tenant/keyVault.ts
    - ../sandbox-conduit (1)/src/components/TheSand.tsx
  symbols:
    - fetchChatCompletion
    - getGenerationSettings
    - gateManagedCompile
    - executeCompile
    - resolveProviderApiKey
  confidence: High
  evidence_type:
    - implementation
    - api
counter_evidence:
  files_inspected:
    - ../sandbox-conduit (1)/src/cloudDriveProviders.ts
    - ../sandbox-os-core/spread/host/spread-host.mjs
```

## Halt

Pass 2 module audit for Provider System & Model Routing complete.
