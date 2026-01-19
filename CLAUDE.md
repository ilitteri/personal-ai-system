# Project Rules

When starting a conversation, confirm you've read this by saying:

> "CLAUDE.md loaded. Standing rules active. [Context status]. [Workstream status]."

Where context status is one of:
- "Context loaded: {project-name}" — if context file exists
- "New context created: {project-name}" — if you created one
- "Using binnacle" — if in ~/Personal/

Where workstream status is one of:
- "Focus: {workstream-name}" — if inferred from branch or only one active
- "Active workstreams: {list}" — if multiple and couldn't infer, then ask which one
- Omit if no workstreams defined yet

---

## Context Management

**At conversation start:**
1. Determine project identity:
   - If git repo: extract org/repo from remote (e.g., `org/repo` → `org-repo`)
   - If not git: use directory name
2. Look for `~/Personal/contexts/{project-identity}.md`
3. If exists: read it
4. If missing: create from `~/Personal/contexts/_template.md`
5. Exception: if in `~/Personal/`, use `binnacle.md` instead

**Workstream detection:**
1. Check the Active Workstreams section in context file
2. Get current git branch name
3. Match branch against workstream names (branch should contain workstream name)
4. If single match: that's the current focus
5. If no match or multiple active: list them and ask user which one
6. Common branch patterns: `feature/workstream-description`, `workstream/thing`, `fix/workstream-bug`

**During conversation:**
- Update context file after significant changes (decisions, completed milestones, direction changes)
- Update the relevant workstream's status when progress is made

**Before ending:**
- Update context file with current state, session summary, and notes for next session
- Update workstream status if changed

---

## Standing Rules

These apply to ALL work. Customize this section with your own rules.

**Optimization principle:** Execute checks from cheapest to most expensive. Stop early if a cheap check fails.

### Personal AI System

- **NEVER modify `~/Personal/CLAUDE.md` if current directory is ~/Personal** — this is the global source of truth, managed by the user only
- When asked to add context files, use the `contexts/` directory
- If git shows `T` status on a file (type change), investigate before writing — it may be a symlink
- If unsure about any file's role in the personal AI system structure, ask first

### Security

- **Never read API keys, private keys, or environment files** (`.env`, `.env.local`, `credentials.json`, `*.pem`, `*.key`, etc.)
- If a task requires environment variables, ask the user to provide only the variable names (not values)
- Never log, display, or include sensitive data in outputs
- If accidentally exposed to sensitive data, do not reference or repeat it

### Documentation

When documenting, **always include**:

1. **Step-by-step instructions** for running the project (Nixfile/Makefile)
2. **Working examples** with expected inputs and outputs
3. **Architecture diagrams** (system overview, component interaction, data flow)
4. **Technical design** (decisions, rationale, trade-offs, constraints)
5. **References** (links to sources, related docs, external resources)

### Git & Commits

- Do NOT add yourself as co-author of git commits
- Do NOT commit binary files

**Before committing, check in order (stop if any fails):**

| Step | Check | Cost |
|------|-------|------|
| 1 | Nixfile exists (`shell.nix` or `flake.nix`) | Cheap |
| 2 | Makefile exists with proper targets | Cheap |
| 3 | Lint passes | Low |
| 4 | Format passes | Low |
| 5 | Tests pass | Medium |
| 6 | Task is complete (no partial work) | Medium |
| 7 | Documentation is complete | High |

**Commit message format:**
- Single detailed message describing changes
- What was added/changed/fixed, why it was necessary, important details
- No title prefix (no "docs:", "feat:", "Address X:", "Fix Y:", etc.) — start directly with the description
- No co-author attribution
- Organize commits to be easily reviewable (logical units of work) — one logical change per commit, not multiple unrelated changes bundled together

**Example (good):**
```
Move SequencerState to ethrex-l2-common and remove SequencerStatusProvider trait
to simplify the monitor architecture. This avoids a trait with only one implementation.
```

**Example (bad):**
```
Address PR feedback: move SequencerState and fix typo

- Move SequencerState to l2-common
- Fix typo in error.rs
```
(Has title prefix "Address PR feedback:", bundles unrelated changes)

### CI & Quality

- If the project has CI workflows, understand them and run relevant checks locally before creating a PR

### Code Reviews / PR Reviews

**Before reviewing, check in order (stop if any fails):**

| Step | Check | Cost |
|------|-------|------|
| 1 | CI has finished | Cheap |
| 2 | CI is passing | Cheap |
| 3 | PR description matches issue(s) | Low |
| 4 | Check typos/grammar | Low |
| 5 | Tests make sense | Medium |
| 6 | Deep bug analysis (use extended thinking) | High |
| 7 | Suggest improvements | High |

- Do not apply Copilot review suggestions without user approval
- Present suggestions to user first

**Suggestion template (informal):**
1. Problem description
2. Code suggestion
3. Brief explanation

**PR review tracking (`~/Personal/contexts/pr-reviews.md`):**

| Section | Purpose | Statuses |
|---------|---------|----------|
| Reviewing | Others' PRs I'm reviewing | Pending review, Feedback given, Re-review needed, Approved |
| My PRs | PRs I authored | Draft, Open, Feedback received, Changes pushed, Approved, Merged |
| Completed | Closed PRs (either role) | — |

Update when:
- Starting a review → add to "Reviewing" as "Pending review"
- Giving feedback → "Feedback given"
- Author pushes changes → "Re-review needed"
- Receiving feedback on my PR → "Feedback received"
- Pushing changes after feedback → "Changes pushed"
- PR merged/closed → move to "Completed"

Also update brief status in project context file.

**TODO tracking (`~/Personal/contexts/todos.md`):**
- Add tasks to "Active" with project, priority (High/Medium/Low), and optional due date
- Move to "Completed" when done
- Also add brief entry in project context file under "TODOs" section

**Ideas tracking (`~/Personal/contexts/ideas.md`):**
- Add ideas to "Active" with project
- Move to "Explored" with outcome when investigated
- Also add brief entry in project context file under "Ideas" section

### Testing

- Respect project-specific testing rules
- Follow existing test patterns in the codebase
- Ensure tests are meaningful, not just for coverage
- **Do not only test happy paths** — include error cases, edge cases, and boundary conditions
- Include: unit tests, integration tests, edge cases

### Code Sources & IP

<!-- Add restricted/allowed code sources here -->
<!-- Example:
**Restricted (reference only, no code reuse):**
- https://github.com/some-org/some-repo

**Allowed:**
- https://github.com/your-org/
-->

### Starting New Work

When starting a new project, feature, or documentation:
1. Ask the user for sources/references to learn from before beginning
2. Enter plan mode and write the plan to a markdown file (no permission needed)
3. Wait for user approval before implementing

### Context

Before starting work:
- Explore the project structure
- Identify and read relevant documentation, wherever it lives
- If in `~/Personal/`, read `binnacle.md` and `README.md` first
- If unsure where docs are, ask

### Pull Requests

- Do NOT add "Generated with Claude Code" or similar attributions to PR descriptions
- No self-references (do not mention Claude, AI, or automated tools)
- Use repository PR template; fill out all sections
- **Wait for user approval** before creating PR — present draft description first
- Keep PR description in sync with changes

**PR description template (if no repo template exists):**
- Motivation: why this change is needed
- Description: brief description and implementation approach
- How to Test: step-by-step instructions
- Related Issues: closes #XXX
- Checklist: docs updated, tests added, lint passes, etc.

---

## zkVM Summary

**Full context:** `~/Personal/contexts/zkvm_landscape.md`

### Backends

| zkVM | Organization | Status in ethrex |
|------|--------------|------------------|
| ZisK | Polygon | Most Optimized (100% patches) |
| SP1 | Succinct | Production (~80% patches) |
| RISC0 | RISC Zero | Production (~90%, critical gaps) |
| OpenVM | Axiom | Experimental |

### Patch Utilization

| Backend | Critical Gaps |
|---------|---------------|
| **ZisK** | P256 unpatched (no patch exists) |
| **SP1** | ECADD bug (uses ark_bn254), no c-kzg |
| **RISC0** | Keccak/BLS12-381 disabled (require "unstable") |

### Key Issues

- **SP1 ECADD bug** (`precompiles.rs:814`): substrate-bn causes GasMismatch on mainnet
- **RISC0 Keccak/BLS disabled**: patches require "unstable" feature, not production-ready
- **ZisK unique**: only backend with MODEXP precompile

### ZisK Installation from Source (with GPU)

```bash
# 1. Clone and checkout version
git clone https://github.com/0xPolygonHermez/zisk.git
cd zisk && git checkout v0.15.0

# 2. Build with GPU (set CUDA_ARCH for your GPU)
# RTX 3090 = sm_86, RTX 4090 = sm_89, RTX 5090 = sm_100
export CUDA_ARCH=sm_86
cargo build --release --features gpu

# 3. Install binaries
mkdir -p $HOME/.zisk/bin
LIB_EXT=$([[ "$(uname)" == "Darwin" ]] && echo "dylib" || echo "so")
cp target/release/cargo-zisk target/release/ziskemu target/release/riscv2zisk \
   target/release/zisk-coordinator target/release/zisk-worker \
   target/release/libzisk_witness.$LIB_EXT target/release/libziskclib.a $HOME/.zisk/bin

# 4. Install emulator-asm and lib-c
mkdir -p $HOME/.zisk/zisk/emulator-asm
cp -r ./emulator-asm/src $HOME/.zisk/zisk/emulator-asm
cp ./emulator-asm/Makefile $HOME/.zisk/zisk/emulator-asm
cp -r ./lib-c $HOME/.zisk/zisk

# 5. Add to PATH
PROFILE=$([[ "$(uname)" == "Darwin" ]] && echo ".zshenv" || echo ".bashrc")
echo >>$HOME/$PROFILE && echo "export PATH=\"\$PATH:$HOME/.zisk/bin\"" >> $HOME/$PROFILE
source $HOME/$PROFILE

# 6. Install toolchain
cargo-zisk sdk install-toolchain

# 7. Download and extract proving key
wget https://storage.googleapis.com/zisk-setup/zisk-provingkey-0.15.0.tar.gz
tar -xzf zisk-provingkey-0.15.0.tar.gz -C ~/.zisk/
```

### ZisK CUDA Architecture Error Fix

**Error:** `[CUDA] cudaMemcpyToSymbol(...) failed due to: no kernel image is available for execution on the device (209)`

**Cause:** The `libstarksgpu.a` library in cargo's git checkout was pre-compiled for a different GPU architecture (e.g., sm_75) than the target GPU (e.g., RTX 3090 = sm_86).

**Fix:**
```bash
# 1. Delete pre-built GPU libraries from cargo checkout
rm -rf ~/.cargo/git/checkouts/pil2-proofman-*/*/pil2-stark/lib*
rm -rf ~/.cargo/git/checkouts/pil2-proofman-*/*/pil2-stark/build*

# 2. Rebuild ZisK with correct CUDA_ARCH
cd ~/zisk
rm -rf target
export PATH=/usr/local/cuda-13.0/bin:$PATH  # or your CUDA path
export CUDA_ARCH=sm_86  # RTX 3090
cargo build --release --features gpu

# 3. Reinstall ZisK binaries (steps 3-7 from installation above)
```

**Key insight:** Cargo caches the git checkout with pre-built `.a` files. Simply setting `CUDA_ARCH` doesn't trigger a rebuild. You must delete the cached libraries first.

**GPU Architecture Reference:**
| GPU | CUDA Arch |
|-----|-----------|
| RTX 3090 | sm_86 |
| RTX 4090 | sm_89 |
| RTX 5090 | sm_100 |
| A100 | sm_80 |
| H100 | sm_90 |

### ZisK Commands

```bash
# Build guest program
cargo-zisk build --release

# Rom setup (once per ELF)
cargo-zisk rom-setup -e <ELF> -k ~/.zisk/provingKey

# Prove
cargo-zisk prove -e <ELF> -i <INPUT> -o /tmp/proof -a -u -y

# Debug/analyze with ziskemu
ziskemu -e <ELF> -i <INPUT> -D -X -S
```

### Docs

- ZisK: https://0xpolygonhermez.github.io/zisk/
- SP1: https://docs.succinct.xyz/docs/sp1/introduction
- RISC0: https://dev.risczero.com/api
- ethrex zkVM docs: PR #5872 (`docs/prover/zkvm/`)

### ZisK Profiling Workflow

**Step 1: Generate inputs FIRST (critical - state gets pruned)**
```bash
# Generate inputs for a range of blocks (always do this before any proving/profiling)
ethrex-replay generate-input --from <START> --to <END> --rpc-url http://157.180.1.98:8545 --output-dir ./inputs

# Or single block
ethrex-replay generate-input --block <N> --rpc-url http://157.180.1.98:8545 --output-dir ./inputs
```

**Step 2: Build guest program**
```bash
cd crates/l2/prover/src/guest_program/src/zisk
cargo-zisk build --release
# ELF at: target/riscv64ima-zisk-zkvm-elf/release/zkvm-zisk-program
```

**Step 3: Profile with ziskemu**
```bash
export ELF="path/to/zkvm-zisk-program"
ziskemu -e $ELF -i ./inputs/ethrex_mainnet_<BLOCK>_input.bin -D -X -S > profile.txt
```

**Profile output sections:**
- `STEPS` - Total execution steps (correlates with proving time)
- `COST BY OPCODE` - Which operations are expensive
- `TOP STEP FUNCTIONS` - Which functions consume the most steps

### RPC with debug_executionWitness

```
http://157.180.1.98:8545
```

This RPC supports `debug_executionWitness` which is required for generating zkVM inputs.

---

## Benchmarking & Optimization

**Full workflow:** `~/Personal/workflows/benchmarking-workflow.md`

### Critical Rules (Never Violate)

1. **Only run parallel benchmarks when they won't affect results** — GPU/CPU contention invalidates results
2. **Never skip baseline** — All comparisons require a valid baseline
3. **Never modify code during a benchmark run** — Invalidates the run
4. **Always record before deciding** — Log results before making keep/discard decisions
5. **Always test correctness after optimization** — Faster but wrong is useless
6. **Always use multiple inputs** — Single-input optimizations may not generalize

### Workflow Phases

| Phase | Key Actions |
|-------|-------------|
| 1. Knowledge | Request sources, explore codebase, document environment |
| 2. Planning | Create PLAN.md with hypotheses, get user approval |
| 3. Baseline | Run 10+ times per input, verify CV < 10%, test correctness |
| 4. Testing | Branch per experiment, run benchmarks, verify correctness |
| 5. Tracking | Update TRACKER.md after every experiment |
| 6. Observability | Generate HTML report, serve on benchmark machine |
| 7. Notifications | Notify on completion, errors, significant findings |
| 8. Iteration | Compound testing, final report |

### Decision Criteria

| Result | Action |
|--------|--------|
| >5% improvement, correct | **KEEP** |
| 2-5% improvement, correct | **MAYBE** (backlog) |
| <2% improvement | **DISCARD** |
| Any regression | **DISCARD** |
| Incorrect output | **REJECT** |

### Branch Naming

```bash
bench/001-optimization-name       # During testing
bench/001-optimization-name-KEEP  # If successful
bench/001-optimization-name-DISCARD  # If rejected
```

### Key Commands

```bash
# Hyperfine benchmark
hyperfine --warmup 3 --runs 10 --export-json results.json 'command'

# GPU temperature check (should be <50°C before starting)
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader

# Serve report
python3 -m http.server 8080 --directory benchmarks/report
```

---

## Quick Reference Checklists

### Before Commit

- [ ] Nixfile exists
- [ ] Makefile exists
- [ ] Lint passes
- [ ] Format passes
- [ ] Tests pass
- [ ] Task is fully complete
- [ ] Documentation complete (with examples, diagrams, references)

### Before PR Review

- [ ] CI has finished running
- [ ] CI is passing

### Before Creating PR

- [ ] PR description drafted with Motivation and Description
- [ ] User has approved description
- [ ] No self-references in description
- [ ] Template filled correctly

### After Applying PR Feedback

- [ ] PR description updated to reflect changes

### Before Benchmarking

- [ ] Sources gathered and read
- [ ] Plan created and approved
- [ ] Environment documented
- [ ] Baseline established (10+ runs, CV < 10%)
- [ ] Correctness verified
- [ ] Multiple diverse inputs selected

### After Each Benchmark Experiment

- [ ] Cooldown observed (60s minimum)
- [ ] Results recorded immediately
- [ ] Correctness tested
- [ ] TRACKER.md updated
- [ ] Branch renamed (KEEP/DISCARD)
