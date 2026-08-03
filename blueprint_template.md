---
name: "Blueprint Title (human readable)"
slug: "blueprint-slug"         # lowercase, hyphen-separated
description: "One-line summary of purpose"
version: "0.1.0"
author: "Your Name / Org"
date_created: "2026-08-04T00:00:00Z"
tags:
  - creator
  - media
  - mobile
supported_llms:
  - gpt-4o
  - gemini
estimated_runtime_minutes: 4
estimated_cost_usd: 0.40
license: "paid"                # public | paid | restricted | commercial
visibility: "public"            # public | private
inputs:
  - name: topic
    type: string
    required: true
    description: "Core subject or theme for the content pipeline"
  - name: tone
    type: string
    required: false
    default: "informal"
    description: "Voice/tone for generated scripts"
outputs:
  - asset_manifest.json
  - script.md
  - production_schedule.md
notes: |
  Add any important safety, compliance, or usage notes here.
examples:
  - demo_run: "https://example.com/demo"
---

# Blueprint Title (human readable)
Short summary: What this blueprint does and why it exists.

## Intent & Use Cases
- Primary use: (e.g., generate video content pipeline)
- Who should use this: (creators, mobile devs, agencies)

## Input Parameters
Provide the full list of inputs and validation rules.
- topic (string, required) — short description of the subject.
- tone (string, optional) — writing voice; default: "informal".
- max_length (integer, optional) — max tokens/words for generated scripts.

## System Context
Provide the system-level instructions to the LLM(s) and any constraints.
- System instruction (role: system):
  - "You are Aetheria Assistant, a deterministic prompt compiler. Output must follow the required artifact schema in the 'Validation' section. Do not hallucinate facts; when uncertain, return a clear TODO entry."

## Execution Steps (Prompt Matrix)
A deterministic, ordered list of model calls. For each step include:
- step id
- role (system/user/assistant)
- model hint
- temperature and sampling settings
- prompt template (with interpolation variables)
- expected output format

Example:

Step 1 — Context & Framing
- id: step-1
- role: system
- model_hint: gpt-4o
- params: temperature=0.0, max_tokens=800
- prompt:
  "You are a pipeline compiler. Given the input 'topic: {{topic}}' and 'tone: {{tone}}', produce:
   A) A 5-line creative brief.
   B) A list of 8 named assets (filename + short description).
   Output as JSON with keys: brief, assets."

Step 2 — Script Generation
- id: step-2
- role: user
- model_hint: gpt-4o
- params: temperature=0.2, max_tokens=1200
- prompt:
  "Using the brief from Step 1, write a short-form video script with scene timestamps (mm:ss), and include a call-to-action at end. Output as markdown."

Step 3 — Asset Manifest to CSV
- id: step-3
- role: assistant
- model_hint: gemini
- params: temperature=0.0, max_tokens=400
- prompt:
  "Convert the assets list to an asset_manifest.json: array of objects {filename, type, duration_est, notes}."

## Validation Rules
Define structural checks for outputs (automated tests).
- Step 1 output must be valid JSON with keys: brief, assets (array, >=1).
- Script must include at least one CTA and no offensive language (apply your moderation checks).
- Asset manifest must be valid JSON.

## Expected Output Artifacts (filenames + description)
- asset_manifest.json — structured JSON list of production assets.
- script.md — human-readable script with timestamps.
- production_schedule.md — simple schedule and tasks (CSV/Markdown).
- run_log.txt — execution log with step outputs and cost estimation.

## Example Run (input → expected artifacts)
Input:
- topic: "How to grow microgreens at home"
- tone: "friendly"

Expected:
- script.md (3–5 scenes)
- asset_manifest.json (5 assets)
- production_schedule.md (2-day shoot plan)

## Safety & Compliance
- Notes about not using outputs as medical advice, etc.
- For sensitive domains, require manual review before publishing.

## Version History
- 0.1.0 — template created (2026-08-04)
- 0.1.1 — add validation checks (YYYY-MM-DD)

## Maintenance Notes
- Add tests in repo/tests/run_blueprint_tests.sh to smoke test every blueprint at CI.
- Ensure blueprint frontmatter conforms to manifest.yaml schema.
