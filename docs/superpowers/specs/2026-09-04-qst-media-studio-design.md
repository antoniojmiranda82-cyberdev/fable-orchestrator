# QST Media Studio Design

## Goal
Build a dedicated QST Media Studio product that turns plain-language creative requests into finished social videos and long-form animated projects, then packages each asset with platform-specific copy and publishing actions.

## Product Boundary
QST Media Studio is a standalone product/repository, not a feature embedded into the main QST corporate website. The initial product serves Antonio/QST directly. Multi-tenant customer SaaS can be added later without changing the core media pipeline.

## Primary User Experiences

### 1. Social Video Studio
A user uploads a long-form video and gives a natural-language instruction such as "make five funny viral clips." The system transcribes the source, detects candidate moments, ranks them, creates vertical social edits, adds captions and light motion treatments, generates platform-specific titles/copy/hashtags, and returns finished exports.

### 2. AI Edit Studio
A user uploads an existing clip and asks for targeted changes such as reframing to 9:16, removing or replacing a background, deleting an unwanted object, changing visual mood, enhancing quality, or creating alternate versions. Deterministic edits use the local media stack; generative edits route to a supported AI video-editing provider.

### 3. Long-Form Animation Studio
A user describes a 30+ minute animated episode or film. The system generates a script and storyboard, decomposes the story into independently renderable scenes, maintains character/voice/visual references, generates scene assets, performs voice and lip-sync passes, assembles the episode, runs continuity/quality checks, and allows failed scenes to be regenerated without restarting the entire project.

### 4. Content Pack
For every finished asset the system can produce: title options, hook options, captions, descriptions, hashtags, thumbnail concepts/assets, CTA suggestions, and platform-specific versions for YouTube, YouTube Shorts, TikTok, Instagram Reels, and Facebook Reels.

### 5. Publish
Users can connect supported social accounts and either publish immediately or schedule posts. Platform adapters must be isolated so each network can be enabled, disabled, or changed without affecting rendering.

## Recommended Architecture

### Orchestration
Fable/Jarvis acts as the workflow coordinator. It receives the user's goal, creates a project plan, dispatches specialist workers, tracks state, handles retries, and presents progress/results.

### Media Analysis
- WhisperX: transcription, diarization/timing where supported, word-level timestamps.
- Clip/scene analysis: Clip-Anything plus selected logic from the heatmap/AI clipping repos.
- Clip scoring: rank moments for humor, hook strength, clarity, controversy, emotional impact, or user-selected goals.

### Deterministic Media Processing
- FFmpeg: canonical low-level media engine for probing, transcode, crop, scale, audio normalization, frame extraction, muxing, and final encoding.
- MoviePy: higher-level Python editing/assembly where it reduces implementation complexity.
- Remotion: polished animated captions, motion graphics, branded layouts, and social templates.

### Generative Media Processing
AI video editing/generation is exposed behind a provider-neutral adapter. The application must not couple project state to one provider. Supported tasks include targeted video edits, outpainting/reframing, background/object changes, enhancement, generated inserts, and scene generation.

### Long-Form Animation Pipeline
Project -> script -> storyboard -> scene manifests -> scene generation -> voice -> lip-sync -> scene QC -> episode assembly -> final QC -> export.

Each scene is a durable unit with its own status, references, prompt, source assets, output assets, retry count, and QC result.

## Core Domain Objects

### Project
- id
- type: social_edit | ai_edit | animation
- title
- status
- user_request
- created_at / updated_at

### SourceAsset
- id
- project_id
- media_type
- storage_url
- duration
- width / height
- metadata

### Transcript
- project_id
- segments
- words
- speakers when available

### ClipCandidate
- start / end
- transcript_excerpt
- scores by goal
- rationale
- selected

### RenderJob
- id
- project_id
- job_type
- provider
- input_refs
- status
- retry_count
- output_refs
- error

### AnimationScene
- id
- project_id
- order
- script_text
- storyboard_ref
- character_refs
- voice_refs
- generation_prompt
- status
- output_ref
- qc_status

### ContentPack
- project_id
- platform
- title
- caption
- description
- hashtags
- thumbnail_ref
- cta

### PublishJob
- project_id
- platform
- scheduled_at
- status
- remote_post_id
- error

## Initial Web App Structure

### Dashboard
Recent projects, new-project actions, processing queue, completed exports.

### Upload/Create
One prominent prompt box plus drag-and-drop upload. User picks: Edit My Video, Make Social Clips, or Create Animation.

### Project Workspace
Shows source, transcript/scene plan, generated clips/scenes, progress, approvals, retry/regenerate controls, and final exports.

### Content Pack
Side-by-side platform tabs for TikTok, Instagram, Facebook, YouTube, and Shorts.

### Publish
Connected accounts, schedule controls, per-platform preview, publish status.

### Library
All source assets, rendered clips, thumbnails, long-form projects, and reusable characters/voices.

## V1 Scope

The first shippable version focuses on social-video editing because it produces immediate value and validates the orchestration/rendering foundation.

V1 includes:
- video upload
- media probe/validation
- WhisperX transcription
- candidate clip generation
- AI/rule-based clip scoring
- manual candidate approval
- 9:16 social render
- captions
- basic punch-in/zoom templates
- dead-air trimming
- final MP4 export
- title/caption/hashtag generation
- project history

V1 does not require social-account publishing or 30+ minute animation generation to ship.

## V2 Scope
Add generative editing, thumbnail generation, richer Remotion templates, batch variants, and direct/scheduled publishing.

## V3 Scope
Add long-form animation: script/storyboard tools, character and voice libraries, scene queue, continuity references, scene regeneration, episode assembly, and final QC.

## Reliability Requirements
- Long-running tasks must be asynchronous and resumable.
- Every job must have explicit states and durable progress.
- Retries must be scoped to failed jobs/scenes, never restart an entire long-form project unnecessarily.
- Source files and outputs must be immutable; new edits create derived assets.
- Provider failures must produce readable errors and allow alternate-provider retry where possible.
- Final exports must pass media validation before being marked complete.

## Security Requirements
- Signed/private asset URLs.
- Strict file type and size validation.
- No provider credentials in client code.
- Per-project authorization boundaries.
- Social OAuth tokens encrypted at rest and scoped minimally.
- Uploaded/generated media is private by default.

## Testing Strategy
- Unit tests for scoring, job-state transitions, render manifests, and platform-copy generation.
- Contract tests for provider adapters.
- Integration tests for upload -> transcript -> candidate -> render -> export.
- Golden-media tests for FFmpeg/Remotion output properties.
- End-to-end browser test for the complete V1 workflow.
- Failure tests for provider timeouts, render crashes, corrupt uploads, and retry/resume behavior.

## Success Criteria for V1
A user can upload one long-form video, ask for a set of social clips, review generated candidates, render selected clips as captioned 9:16 MP4s, and receive a platform-specific content pack without using an external editor.

## Repository Strategy
Create a dedicated repository named `qst-media-studio`. This design document may live in Fable Orchestrator until the new repository is created; the implementation plan must begin by creating/scaffolding the dedicated product repository and copying the approved spec into it.
