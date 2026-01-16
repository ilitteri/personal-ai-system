# Benchmarking & Optimization Workflow

A standardized workflow for running benchmarks, testing optimizations, and tracking results. Designed for reproducibility across sessions and team members.

> **Version:** 1.1.0
> **Last Updated:** 2026-01-16

---

## Overview

This workflow covers:
1. Knowledge gathering and planning
2. Baseline establishment
3. Optimization exploration and testing
4. Results tracking and observability
5. Iteration and compound testing

---

## Critical Rules

These rules must NEVER be violated:

1. **Never run parallel benchmarks** — Resource contention invalidates results
2. **Never skip baseline** — All comparisons require a valid baseline
3. **Never modify code during a benchmark run** — Invalidates the run
4. **Always record before deciding** — Log results before making keep/discard decisions
5. **Always test correctness after optimization** — Faster but wrong is useless
6. **Always use multiple inputs** — Single-input optimizations may not generalize

---

## Phase 1: Knowledge Gathering

### 1.1 Request Sources

**Before starting any benchmarking work, request sources from the user:**

```
I need sources to build context before planning. Please provide:
1. Relevant documentation (internal docs, RFCs, design docs)
2. Existing benchmarks or profiling data
3. Known bottlenecks or areas of concern
4. Related academic papers or blog posts (if applicable)
5. Similar optimization efforts (past PRs, issues)
6. Constraints (time budget, acceptable regressions, etc.)
```

### 1.2 Codebase Exploration

After receiving sources:
- Read all provided materials thoroughly
- Explore the codebase for existing benchmarks (use as templates)
- Identify the critical path and hot functions
- Document initial hypotheses

### 1.3 Environment Documentation

Record the benchmark environment:

```yaml
# benchmarks/environment.yaml
machine:
  hostname: ethrex-office-2
  cpu: AMD Ryzen 9 5950X
  gpu: NVIDIA RTX 3090
  memory: 64GB
  os: Debian GNU/Linux 13

toolchain:
  rust: 1.84.0
  cuda: 13.0
  zisk: v0.15.0  # or relevant tool version

commit: abc123def  # exact commit being benchmarked
date: 2026-01-16
```

---

## Phase 2: Planning

### 2.1 Create Comprehensive Plan

After gathering knowledge, create a detailed plan:

```markdown
# benchmarks/PLAN.md

## Objective
[Clear statement of what we're optimizing and success criteria]

## Baseline Metrics
[Current performance numbers, to be filled after baseline runs]

## Hypotheses
[Ranked list of optimization ideas with expected impact]

1. **[HIGH] MPT Hash Caching**
   - Expected impact: 20-40% reduction in hash computation
   - Risk: Memory increase
   - Conflicts with: None

2. **[MEDIUM] Zero-copy deserialization**
   - Expected impact: 5-10% reduction in deserialization
   - Risk: API changes required
   - Conflicts with: #3

## Attack Plan
[Ordered sequence of optimizations to test]

## Success Criteria
- Minimum improvement threshold: 5%
- Statistical significance: p < 0.05
- No regressions in other metrics
```

### 2.2 Plan Review

Present the plan to the user for approval before proceeding.

---

## Phase 3: Baseline Establishment

### 3.1 Pre-Benchmark Checks

Before running benchmarks:

```bash
# Check GPU temperature (should be <50°C before starting)
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader

# Check no other heavy processes
htop  # or ps aux

# Record system state
uptime
free -h
```

### 3.2 Input Diversity

**Never benchmark with a single input.** Select diverse inputs:

```yaml
# benchmarks/inputs.yaml
inputs:
  - name: "light_block"
    path: "./inputs/block_1000_light.bin"
    description: "Few transactions, no precompiles"

  - name: "heavy_keccak"
    path: "./inputs/block_2000_keccak_heavy.bin"
    description: "Many storage operations"

  - name: "precompile_heavy"
    path: "./inputs/block_3000_ecrecover.bin"
    description: "Many signature verifications"

  - name: "typical"
    path: "./inputs/block_4000_typical.bin"
    description: "Representative average block"
```

For random input generation:
- Use deterministic seeds for reproducibility
- Document the seed in results
- Generate at least 5 diverse inputs

### 3.3 Baseline Runs

Run baseline **minimum 10 times per input**:

```bash
for input in inputs/*.bin; do
  hyperfine \
    --warmup 3 \
    --runs 10 \
    --export-json "benchmarks/baseline/$(basename $input .bin).json" \
    "your-benchmark-command --input $input"
done
```

### 3.4 Multi-Metric Baseline

Track multiple metrics, not just time:

```yaml
# benchmarks/baseline/metrics.yaml
primary:
  time_seconds: 262.0
  time_stddev: 5.2

secondary:
  memory_peak_mb: 8500
  gpu_utilization_percent: 85
  proof_size_bytes: 1048576

profile:  # From profiler output
  top_functions:
    - name: "Node::memoize_hashes"
      cost_percent: 59.08
    - name: "LEVM::execute_tx"
      cost_percent: 36.58
```

### 3.5 Baseline Validation

- Check coefficient of variation (CV) < 10%
- If CV > 10%:
  1. Check for thermal throttling (GPU temp)
  2. Check for background processes
  3. Increase cooldown between runs
  4. If still unstable, document and proceed with wider error bars
- Record baseline metrics in `PLAN.md`
- **Run correctness test** — Verify output is correct before proceeding

---

## Phase 4: Optimization Testing

### 4.1 Branch Strategy

For each optimization:

```bash
# Create experiment branch from baseline
git checkout -b bench/001-optimization-name

# After testing, if successful:
git checkout -b bench/001-optimization-name-KEEP

# If discarded:
git checkout -b bench/001-optimization-name-DISCARD
```

### 4.2 Experiment Structure

Each experiment gets a directory:

```
benchmarks/experiments/001-mpt-hash-cache/
├── hypothesis.md    # What we're testing and why
├── changes.patch    # Git diff of changes
├── results.json     # Hyperfine output
├── profile.txt      # Profiler output (ziskemu, perf, etc.)
└── verdict.md       # Decision and reasoning
```

### 4.3 Running Experiments

```bash
# Cooldown between experiments (GPU/thermal)
sleep 60

# Run with same parameters as baseline
hyperfine \
  --warmup 3 \
  --runs 10 \
  --export-json benchmarks/experiments/001/results.json \
  'your-benchmark-command'
```

### 4.4 Correctness Testing

**Before accepting any optimization, verify correctness:**

```bash
# Run correctness test after optimization
./run_correctness_tests.sh

# For zkVM: verify proof validates
cargo-zisk verify -p /tmp/proof

# Compare outputs
diff baseline_output.bin optimized_output.bin
```

An optimization that produces incorrect results is **immediately rejected**, regardless of speedup.

### 4.5 Decision Criteria

| Result | Action |
|--------|--------|
| >5% improvement, p<0.05, correct | **KEEP** - merge to accumulator branch |
| 2-5% improvement, correct | **MAYBE** - keep in backlog, may compound |
| <2% improvement | **DISCARD** - overhead not worth it |
| Any regression | **DISCARD** - immediate rejection |
| Timeout (>1.10x baseline) | **KILL** - abort run, mark as failed |
| Incorrect output | **REJECT** - critical failure |

**Context-dependent thresholds:**
- For already-optimized code: accept >2% improvements
- For first-pass optimization: require >5% improvements
- Document threshold used in PLAN.md

### 4.6 Edge Cases

**Flaky results (high variance across runs):**
1. Increase run count to 20
2. Remove outliers (>2σ from mean)
3. If still flaky, mark as INCONCLUSIVE
4. Try with different inputs

**Improves some inputs, regresses others:**
1. Calculate weighted average based on input frequency
2. If net positive and no input regresses >5%: KEEP
3. If any input regresses >5%: DISCARD or make input-conditional

**Two optimizations conflict:**
1. Test each independently
2. Test both together
3. If A+B < max(A, B): they conflict
4. Keep only the better one

**Optimization breaks on edge cases:**
1. Add the edge case to test inputs
2. If fixable: fix and re-test
3. If not fixable: DISCARD

### 4.7 Parallel vs Sequential

- **Parallel exploration**: Multiple agents can research and prototype independent optimizations simultaneously
- **Sequential validation**: All benchmark runs must be sequential to avoid resource contention
- **Never run parallel proofs/benchmarks**: GPU contention invalidates results

---

## Phase 5: Tracking & Memory

### 5.1 Tracker File

Maintain a living document:

```markdown
# benchmarks/TRACKER.md

## Session: 2026-01-16

### Baseline
- Metric: 262 seconds per proof
- Commit: abc123

### Experiments Tested

| # | Name | Result | Δ% | Status | Notes |
|---|------|--------|-----|--------|-------|
| 001 | MPT hash cache | 245s | -6.5% | ✅ KEEP | Merged to accumulator |
| 002 | Zero-copy rkyv | 260s | -0.8% | ❌ DISCARD | Below threshold |
| 003 | Batch signatures | crash | N/A | ❌ FAILED | Stack overflow |

### Key Learnings
1. MPT hashing dominates cost (59%) - confirmed by profiling
2. rkyv already well-optimized, minimal gains possible
3. [Add learnings as you discover them]

### Ideas Backlog
- [ ] Try arena allocator for trie nodes
- [ ] Investigate parallel hash computation
- [x] ~~Zero-copy deserialization~~ (tested, discarded)

### Conflicts Matrix
| Opt A | Opt B | Conflict? |
|-------|-------|-----------|
| 001 | 004 | Yes - both modify Node |
| 002 | 003 | No |
```

### 5.3 Historical Tracking

Maintain history across sessions in a structured format:

```yaml
# benchmarks/HISTORY.yaml
sessions:
  - date: "2026-01-16"
    commit: "abc123"
    baseline: 262s
    final: 198s
    improvement: -24.4%
    optimizations_kept: ["001", "004", "007"]
    key_learnings:
      - "MPT hashing dominates at 59%"
      - "memcpy overhead is significant"

  - date: "2026-01-10"
    commit: "def456"
    baseline: 310s
    final: 262s
    improvement: -15.5%
    optimizations_kept: ["001", "002"]
    key_learnings:
      - "Deserialization was 20% of cost"
```

This enables:
- Detecting regressions across sessions
- Building on previous learnings
- Avoiding re-testing discarded ideas

### 5.2 Update Frequency

- Update TRACKER.md **after every experiment**
- Update PLAN.md when priorities change
- Commit tracking files with each experiment

---

## Phase 6: Observability & Frontend

### 6.1 Report Structure

Generate a static HTML report:

```
benchmarks/report/
├── index.html          # Main dashboard
├── style.css           # Styling
├── data.json           # All results data
├── charts/             # Generated visualizations
└── experiments/        # Per-experiment details
```

### 6.2 Dashboard Contents

The dashboard must include:

1. **Overview Section**
   - Current status (running/complete)
   - Progress (X/Y experiments done)
   - Best improvement so far
   - Time elapsed

2. **Baseline Section**
   - Environment details
   - Baseline metrics with confidence intervals

3. **Experiments Table**
   - All experiments with status, results, verdict
   - Sortable by improvement %

4. **Trend Chart**
   - X-axis: experiment number
   - Y-axis: performance metric
   - Show baseline as horizontal line

5. **Current Run** (if running)
   - Which experiment
   - Progress indicator
   - Live logs (last 50 lines)

6. **Learnings Section**
   - Key findings from TRACKER.md

### 6.3 Auto-Refresh

```html
<!-- Add to index.html head -->
<meta http-equiv="refresh" content="30">
```

Or JavaScript-based:
```javascript
setTimeout(() => location.reload(), 30000);
```

### 6.4 Serving the Report

```bash
# Simple HTTP server on the benchmark machine
cd benchmarks/report && python3 -m http.server 8080 &

# Or use a specific port
python3 -m http.server 9999 --bind 0.0.0.0
```

---

## Phase 7: Notifications

### 7.1 Slack Integration

Store webhook URL securely:

```bash
# On the benchmark server, create:
mkdir -p ~/.config/benchmarks
echo "SLACK_WEBHOOK=https://hooks.slack.com/..." > ~/.config/benchmarks/secrets.env
chmod 600 ~/.config/benchmarks/secrets.env
```

Notification script:

```bash
#!/bin/bash
# ~/.local/bin/notify-benchmark
source ~/.config/benchmarks/secrets.env

MESSAGE="$1"
curl -s -X POST "$SLACK_WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d "{\"text\": \"$MESSAGE\"}"
```

### 7.2 When to Notify

- Baseline complete
- Each experiment complete (with result summary)
- Significant finding (>10% improvement)
- Error or crash
- All experiments complete

### 7.3 Message Format

```
🔬 [Benchmark] Experiment 001 Complete
━━━━━━━━━━━━━━━━━━━━━━━
Name: MPT Hash Caching
Result: 245s (baseline: 262s)
Improvement: -6.5% ✅
Status: KEEP
━━━━━━━━━━━━━━━━━━━━━━━
Progress: 3/12 experiments
Dashboard: http://ethrex-office-2:8080/
```

---

## Phase 8: Iteration

### 8.1 After Initial Plan Complete

Once all planned experiments are done:

1. Review results and learnings
2. Identify new hypotheses based on findings
3. Test compound optimizations (combinations of KEEPs)
4. Look for second-order effects

### 8.2 Compound Testing

After individual optimizations:

```markdown
## Compound Experiments

| Combination | Expected | Actual | Verdict |
|-------------|----------|--------|---------|
| 001 + 004 | -15% | -12% | ✅ KEEP |
| 001 + 004 + 007 | -20% | -18% | ✅ KEEP |
```

### 8.3 Diminishing Returns

Stop iterating when:
- Last 3 experiments all showed <1% improvement
- No more hypotheses in backlog
- Time budget exhausted

### 8.4 Final Report

Generate a summary:

```markdown
# benchmarks/FINAL_REPORT.md

## Summary
- Baseline: 262s
- Final: 198s
- Total improvement: -24.4%

## Optimizations Applied
1. MPT Hash Caching (-6.5%)
2. Arena Allocator (-8.2%)
3. Parallel Hashing (-12.1%)

## Optimizations Discarded
[List with reasons]

## Recommendations for Future Work
[Ideas that showed promise but need more investigation]
```

---

## Agent Orchestration

### Coordinator Agent

The coordinator agent:
- Maintains the PLAN.md and TRACKER.md
- Assigns experiments to worker agents
- Aggregates results
- Makes keep/discard decisions
- Generates reports and notifications

### Worker Agents

Worker agents:
- Receive a single optimization to test
- Implement the change
- Run the benchmark
- Report results back to coordinator
- Do NOT run benchmarks in parallel with other workers

### Communication Protocol

```yaml
# Coordinator -> Worker
task:
  id: 001
  name: "MPT Hash Caching"
  hypothesis: "Caching intermediate hashes will reduce recomputation"
  baseline: 262s
  timeout: 288s  # 1.10x baseline

# Worker -> Coordinator
result:
  id: 001
  status: success  # or: failed, timeout, error
  time: 245s
  improvement: -6.5%
  profile: "path/to/profile.txt"
  patch: "path/to/changes.patch"
```

---

## Checklist

### Before Starting
- [ ] Sources gathered and read
- [ ] Plan created and approved
- [ ] Environment documented
- [ ] Baseline established (10+ runs, CV < 10%)
- [ ] Report server running
- [ ] Notifications configured

### During Experiments
- [ ] Cooldown between runs (60s minimum)
- [ ] Results recorded immediately
- [ ] TRACKER.md updated after each experiment
- [ ] Report regenerated

### After Completion
- [ ] Final report generated
- [ ] All branches properly named (KEEP/DISCARD)
- [ ] Learnings documented
- [ ] Notifications sent
- [ ] Report archived

---

## Reference Commands

```bash
# Hyperfine with all options
hyperfine \
  --warmup 3 \
  --runs 10 \
  --timeout 300 \
  --export-json results.json \
  --export-markdown results.md \
  --show-output \
  'command'

# ZisK proof with timing
time cargo-zisk prove -e $ELF -i $INPUT -o /tmp/proof -a -u -y

# ZisK profiling
ziskemu -e $ELF -i $INPUT -D -X -S > profile.txt

# GPU monitoring
watch -n 1 nvidia-smi

# Serve report
python3 -m http.server 8080 --directory benchmarks/report
```

---

## Appendix A: zkVM-Specific Guidelines

When benchmarking zkVM provers (ZisK, SP1, RISC0, etc.):

### A.1 Additional Metrics

Track zkVM-specific metrics beyond time:

| Metric | Description | Why It Matters |
|--------|-------------|----------------|
| **Steps** | Total execution steps | Correlates with proving time |
| **Proof instances** | Number of proof segments | Affects parallelization |
| **Cycles** | CPU cycles in guest | Direct cost measure |
| **Proof size** | Output proof bytes | On-chain verification cost |
| **Memory peak** | Max RAM during proving | Hardware requirements |
| **GPU utilization** | % GPU used | Efficiency measure |

### A.2 Profiler Commands

```bash
# ZisK profiling
ziskemu -e $ELF -i $INPUT -D -X -S > profile.txt

# SP1 profiling
TRACE_FILE=trace.json cargo run --release -- prove

# RISC0 profiling
RISC0_PPROF_OUT=profile.pb cargo run --release
```

### A.3 Block Selection for zkVM

Select blocks with diverse characteristics:

| Block Type | Characteristics | Why Include |
|------------|-----------------|-------------|
| Light | <50 txs, no precompiles | Lower bound |
| Keccak-heavy | Many storage ops | Tests hash optimization |
| ECRECOVER-heavy | Many signatures | Tests secp256k1 patch |
| Precompile-heavy | BN254, BLS12-381 | Tests crypto patches |
| Large state | Many unique accounts | Tests MPT handling |
| Typical | Average mainnet block | Representative case |

### A.4 Proof Timeouts by GPU

| GPU | Timeout (1.10x) | Expected Range |
|-----|-----------------|----------------|
| RTX 3090 | ~5 min typical | 3-8 min |
| RTX 4090 | ~2 min typical | 1-4 min |
| RTX 5090 | ~1 min typical | 0.5-2 min |
| H100 | ~30s typical | 20s-1 min |

### A.5 Common zkVM Optimization Targets

| Target | Typical Impact | Approach |
|--------|----------------|----------|
| MPT hashing | 40-60% of cost | Cache, lazy compute |
| Deserialization | 5-15% of cost | Zero-copy, compress |
| memcpy | 10-25% of cost | Reduce copies, references |
| Crypto patches | Varies | Ensure all patches active |
| Memory allocation | 5-10% | Arena allocator, pooling |

---

## Appendix B: Report Generator Template

A Python script to generate the HTML report:

```python
#!/usr/bin/env python3
# benchmarks/scripts/generate_report.py

import json
import os
from datetime import datetime
from pathlib import Path

def generate_report(benchmarks_dir: Path, output_dir: Path):
    """Generate HTML report from benchmark results."""

    # Load all results
    results = load_results(benchmarks_dir)
    baseline = load_baseline(benchmarks_dir)

    # Generate HTML
    html = f"""<!DOCTYPE html>
<html>
<head>
    <title>Benchmark Report - {datetime.now().strftime('%Y-%m-%d')}</title>
    <meta http-equiv="refresh" content="30">
    <style>
        body {{ font-family: -apple-system, sans-serif; margin: 2rem; }}
        .card {{ border: 1px solid #ddd; padding: 1rem; margin: 1rem 0; border-radius: 8px; }}
        .success {{ background: #d4edda; }}
        .failure {{ background: #f8d7da; }}
        .pending {{ background: #fff3cd; }}
        table {{ border-collapse: collapse; width: 100%; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background: #f5f5f5; }}
    </style>
</head>
<body>
    <h1>Benchmark Report</h1>
    <p>Last updated: {datetime.now().isoformat()}</p>

    <div class="card">
        <h2>Overview</h2>
        <p>Baseline: {baseline['time']}s</p>
        <p>Best so far: {min(r['time'] for r in results if r.get('time'))}s</p>
        <p>Progress: {len([r for r in results if r['status'] == 'complete'])}/{len(results)}</p>
    </div>

    <div class="card">
        <h2>Experiments</h2>
        <table>
            <tr><th>#</th><th>Name</th><th>Time</th><th>Δ%</th><th>Status</th></tr>
            {''.join(format_experiment_row(r, baseline) for r in results)}
        </table>
    </div>
</body>
</html>"""

    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / 'index.html').write_text(html)

if __name__ == '__main__':
    generate_report(Path('benchmarks'), Path('benchmarks/report'))
```

---

## Appendix C: Emergency Procedures

### C.1 Benchmark Machine Becomes Unavailable

1. Check if results were auto-saved (they should be after each run)
2. Resume from last checkpoint when machine returns
3. Re-run the interrupted experiment from scratch
4. Do NOT attempt to continue a partially-completed run

### C.2 Results Look Suspicious

1. **Stop immediately** — Don't discard or keep based on suspicious data
2. Check for thermal throttling: `nvidia-smi -q -d TEMPERATURE`
3. Check for background processes: `htop`
4. Re-run baseline to verify environment
5. If baseline changed: restart entire session with new baseline

### C.3 Optimization Causes Crash

1. Log the crash details (backtrace, error message)
2. Mark experiment as FAILED
3. Create minimal reproduction case
4. File bug if it's a toolchain issue
5. Move to next experiment

### C.4 Running Out of Time

1. Prioritize: finish in-progress experiments
2. Skip lowest-priority remaining experiments
3. Document what was skipped and why
4. Generate partial report with available data
5. Add skipped experiments to backlog for next session

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2026-01-16 | Add critical rules, input diversity, correctness testing, edge cases, historical tracking, zkVM appendix |
| 1.0.0 | 2026-01-16 | Initial version |
