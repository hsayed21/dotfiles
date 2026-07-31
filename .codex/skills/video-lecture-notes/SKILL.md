---
name: video-lecture-notes
description: Analyze local or online programming and course videos using ClaudeTube MCP. Use when the user asks to transcribe a lecture, inspect visible code or technical screens, reconstruct examples, and generate concise, technically complete, Obsidian-ready Markdown notes for any programming language, framework, database, operating system, tool, platform, or technical subject.
---

# Technical Video Lecture Notes

Use the configured `claudetube` MCP server to reconstruct programming and technical lectures from local videos or supported online video URLs.

This skill is technology-independent.

It must work with subjects such as:

- C, C++, C#, Java, Kotlin, Python, JavaScript, TypeScript, Go, Rust, PHP, Ruby, Swift, Dart, and other languages;
- .NET, ASP.NET Core, Angular, React, Vue, Node.js, Spring, Django, Laravel, Flutter, and other frameworks;
- SQL Server, PostgreSQL, MySQL, Oracle, MongoDB, Redis, and other databases;
- Docker, Kubernetes, Git, Linux, Windows, cloud platforms, CI/CD, networking, cybersecurity, system administration, and DevOps;
- architecture, algorithms, data structures, APIs, testing, debugging, design patterns, and software engineering;
- any technical lecture containing explanations, code, commands, configuration, diagrams, slides, or software demonstrations.

Do not assume the subject is Angular.

Detect the actual language, framework, tool, platform, and technical context from the video evidence.

## Main objective

Reconstruct the complete lecture using three information sources:

1. What the instructor says.
2. What appears visually on screen.
3. The chronological relationship between the explanation and the demonstrated work.

The final output must contain:

1. A complete timestamped transcript.
2. Polished technical lecture notes.
3. Visible code and technical artifacts.
4. A timeline of topics and actions.
5. Clearly documented uncertainties.

This is not transcript-only summarization.

This is not code-only extraction.

## Supported inputs

Accept:

- local video files;
- YouTube URLs;
- other video URLs supported by ClaudeTube.

For a local video:

- verify that the file exists;
- resolve it to an absolute path;
- do not move, rename, or modify the original file;
- save generated content in the location requested by the user.

For an online video:

- verify that ClaudeTube can process the URL;
- use the best available transcript and visual quality;
- report access or download failures honestly.

## Mandatory ClaudeTube workflow

Use the available ClaudeTube MCP tools to:

1. Inspect the video metadata.
2. Process the complete video.
3. retrieve the full timestamped transcript.
4. Detect scenes and important visual changes.
5. Identify sections containing:
   - source code;
   - markup;
   - stylesheets;
   - queries;
   - terminal commands;
   - terminal output;
   - configuration files;
   - project structures;
   - browser output;
   - developer tools;
   - desktop applications;
   - database tools;
   - API clients;
   - logs;
   - errors and stack traces;
   - diagrams;
   - charts;
   - slides;
   - tables;
   - formulas;
   - settings and user interfaces.
6. Extract high-quality frames when text, code, commands, diagrams, or configuration must be read.
7. Inspect adjacent frames when:
   - the instructor is typing;
   - the screen is scrolling;
   - autocomplete obscures content;
   - a tooltip or menu covers content;
   - text is blurred;
   - only part of a file is visible;
   - the instructor changes a small section of code;
   - terminal output appears briefly.
8. Combine transcript context with visual evidence.
9. Never rely only on captions.
10. Never claim that visual content was captured unless relevant frames were actually inspected.

## Layer 1 — Raw transcript

Create a complete timestamped transcript representing what the instructor said.

The transcript must:

- preserve meaningful explanations;
- preserve technical terminology;
- preserve product, framework, API, library, class, method, file, command, and configuration names;
- preserve important questions, warnings, and reasoning;
- retain timestamps;
- remove only clearly meaningless recognition artifacts;
- correct obvious speech-recognition errors when strongly supported by context;
- mark uncertain terminology instead of guessing.

Do not rewrite the raw transcript as polished notes.

Keep it as a separate reference file.

## Layer 2 — Polished lecture notes

Transform the transcript and visual evidence into structured Markdown suitable for Obsidian.

The notes must:

- preserve every meaningful technical detail;
- avoid over-summarization;
- remove greetings, filler speech, pauses, typing silence, and repetition that adds no new information;
- preserve the instructor's teaching sequence;
- keep explanations close to their related examples;
- keep code under the concept it demonstrates;
- explain what changed, why it changed, and what result it produced;
- separate distinct lectures or topics clearly;
- correct obvious transcription and formatting errors;
- avoid unnecessary verbosity;
- avoid generic textbook content that was not part of the lecture;
- avoid repeating the same definition in multiple sections;
- remain useful for revision months later.

Every paragraph should provide technical value.

The result should feel like carefully edited course notes, not a generic article.

## Layer 3 — Code and technical artifacts

Capture all meaningful visible technical content, including when applicable:

- source code;
- HTML or XML;
- CSS, SCSS, or other styling languages;
- SQL and database queries;
- shell, Bash, PowerShell, CMD, or terminal commands;
- JSON, YAML, TOML, XML, INI, environment variables, and configuration;
- API requests and responses;
- logs and stack traces;
- compiler or runtime errors;
- regular expressions;
- file and project structures;
- Git commands and diffs;
- Dockerfiles and Compose files;
- infrastructure definitions;
- test cases;
- browser output;
- database result sets;
- diagrams and data flows;
- formulas and algorithms;
- important UI settings or workflow steps.

## Language and file detection

Detect the correct language and file type from:

- editor syntax;
- file extensions;
- editor tabs;
- project trees;
- imports;
- package or dependency files;
- commands;
- framework conventions;
- instructor speech;
- surrounding visual context.

Do not force code into a language-specific format without evidence.

When the filename is visible or strongly supported, label the code with its filename.

Example:

````md
### `UserService.cs`

```csharp
public sealed class UserService
{
}
```
````

When the filename is unknown, use a descriptive label such as:

```md
### Service implementation shown in the editor
```

Do not invent filenames.

## Code reconstruction rules

Preserve the chronological sequence of code changes.

Do not return only the final code when the teaching process is important.

When possible, explain:

1. The initial state.
2. The change introduced.
3. Why the change was made.
4. The resulting behavior.
5. Any error encountered.
6. How the error was resolved.

Reconstruct complete files only when enough visual evidence exists.

Do not fabricate unseen imports, methods, classes, configuration, or business logic merely to produce a compilable project.

## Technical correction rules

Correct obvious transcription and visual-reading mistakes only when supported by:

- nearby frames;
- syntax rules;
- imports;
- visible filenames;
- instructor speech;
- surrounding code;
- compiler or runtime diagnostics;
- framework conventions.

Common visual mistakes may include:

- braces confused with parentheses;
- `I`, `l`, and `1`;
- `O` and `0`;
- quotation marks;
- angle brackets;
- colons and semicolons;
- generic type syntax;
- command flags;
- filenames and extensions;
- uppercase and lowercase identifiers;
- indentation;
- dots, commas, and underscores.

Do not silently rewrite the instructor's implementation into a preferred style.

Do not modernize, refactor, optimize, or replace older code unless the user explicitly asks.

When the lecture uses an older version, preserve its approach and add a version note only when useful.

## Uncertainty handling

Never guess when content is obscured, cropped, blurred, or missing.

Use:

```md
> [!warning] Unclear from video
> The exact value, identifier, command, or code fragment could not be verified from the available frames.
```

Record all unresolved items in `uncertainties.md`.

Include:

- timestamp;
- affected file or screen;
- unclear content;
- reason it is unclear;
- best supported interpretation, only when useful;
- confidence level.

## Lecture separation

When a video contains multiple lectures or separate topics:

- create one top-level `#` heading per lecture;
- separate lectures with `---`;
- preserve the original order;
- keep examples with their correct lecture;
- do not combine unrelated material.

Example:

```md
# Dependency Injection Fundamentals

...

---

# Service Lifetimes

...
```

## Adaptive Markdown structure

Do not force one fixed structure onto every technical topic.

Choose sections based on the actual lecture.

A concept-focused lecture may use:

```md
# Lecture title

## Introduction and Context

## Core Concepts

## How It Works

## Implementation

## Common Pitfalls

## Practical Applications

## Key Takeaways
```

A coding demonstration may use:

```md
# Lecture title

## Objective

## Initial Project State

## Implementation Steps

### Step 1 — Create the model

### Step 2 — Add the service

### Step 3 — Connect the UI

## Errors and Fixes

## Final Result

## Key Takeaways
```

A debugging lecture may use:

```md
# Lecture title

## Problem

## Symptoms

## Investigation

## Root Cause

## Fix

## Verification

## Lessons Learned
```

A tool or configuration lecture may use:

```md
# Lecture title

## Purpose

## Prerequisites

## Configuration Steps

## Important Options

## Verification

## Common Problems

## Key Takeaways
```

Do not create empty or artificial sections.

## Code-fence detection

Use the correct Markdown language identifier based on the detected content.

Examples include:

- `c`
- `cpp`
- `csharp`
- `java`
- `kotlin`
- `python`
- `javascript`
- `typescript`
- `html`
- `css`
- `scss`
- `sql`
- `json`
- `yaml`
- `xml`
- `toml`
- `bash`
- `powershell`
- `dockerfile`
- `diff`
- `text`

Use `text` for plain terminal output, logs, or unknown formats.

Do not place HTML, SQL, JSON, terminal output, or configuration inside an unrelated programming-language fence.

## Diagrams and visual explanations

When a meaningful diagram appears:

- describe what it represents;
- preserve labels and relationships;
- explain the flow or structure;
- include its timestamp;
- save a screenshot when the output format supports screenshots.

Do not describe decorative visuals.

For architecture or flow diagrams, use Mermaid only when the relationships are clear enough to reconstruct accurately.

Label Mermaid diagrams as reconstructions rather than original images.

## Commands and outputs

Keep commands separate from their output.

Example:

```bash
dotnet build
```

```text
Build succeeded.
0 Warning(s)
0 Error(s)
```

Explain why the command was run and what the result proved.

## Default output structure

Unless the user requests another structure, create:

```text
<lesson-name>/
├── lecture.md
├── transcript.md
├── timeline.md
├── uncertainties.md
├── screenshots/
└── code/
```

Create additional files only when useful, such as:

```text
concepts.md
commands.md
errors-and-fixes.md
build-report.md
diagrams.md
```

Do not create empty files.

## lecture.md

This is the primary polished output.

It must combine:

- the instructor's meaningful explanation;
- visible technical evidence;
- code and commands;
- implementation sequence;
- mistakes and fixes;
- important conclusions.

It must be concise enough to revise easily but complete enough that the user does not need to replay the lecture to recover important information.

## transcript.md

Store the complete timestamped transcript.

Preserve the spoken sequence.

Do not mix polished editorial explanations into the transcript.

## timeline.md

Create a concise timeline table:

```md
| Time | Topic | File or Screen | Action |
|---|---|---|---|
| 00:00–03:15 | Introduction | Slides | Defines the problem |
| 03:16–08:40 | Model creation | `User.cs` | Adds the data model |
| 08:41–12:05 | Database query | SQL editor | Executes and explains the query |
```

Include only meaningful transitions and actions.

## screenshots/

Save only useful screenshots, such as:

- readable code states;
- important diagrams;
- significant errors;
- configuration screens;
- final output.

Avoid saving hundreds of duplicate frames.

Use descriptive filenames containing the timestamp and subject.

## code/

Create reconstructed code files only when sufficient evidence exists.

Preserve folder structure when visible.

Do not invent a complete project from isolated snippets.

## Validation

Use technology-appropriate validation only when enough project information exists.

Examples:

- `.NET`: `dotnet build` or relevant test commands;
- Node.js or TypeScript: package scripts, compiler, or framework build;
- Python: syntax checks or tests;
- Java: Maven or Gradle build;
- C or C++: available compiler or build system;
- SQL: parser or database execution only when a safe configured environment exists;
- Docker: configuration validation;
- configuration files: relevant linting or validation tools.

Before running commands:

- inspect the project;
- identify the actual technology;
- avoid destructive operations;
- do not install large dependencies unless required and permitted;
- do not claim successful validation when only visual inspection was performed.

Validation is used to detect extraction errors.

It is not permission to invent missing code.

Document validation results and remaining failures.

## Notes density

Preserve all meaningful information, but remove noise.

Avoid:

- long introductions;
- generic motivational language;
- repeated conclusions;
- excessive emojis;
- unnecessary analogies;
- explaining obvious syntax line by line;
- unrelated background knowledge;
- artificial headings;
- empty sections;
- repeated definitions.

Use analogies only when the instructor used one or when it significantly improves understanding.

Every word should earn its place.

## Final quality checklist

Before completing the task, verify:

- The complete video was processed.
- The full transcript was retrieved.
- Meaningful visual scenes were inspected.
- High-quality frames were used where needed.
- Spoken and visual information were combined.
- The technology was detected rather than assumed.
- All meaningful technical details were preserved.
- Filler and useless repetition were removed.
- Code and commands appear under their related concepts.
- Separate lectures remain separate.
- Correct code-fence languages were used.
- Errors and fixes were preserved.
- Uncertainty was documented.
- Hidden content was not invented.
- The Markdown is suitable for Obsidian.
- The output is concise, structured, and revision-friendly.
