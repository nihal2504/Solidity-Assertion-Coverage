**This project was entirely conceptualized and originally written by Dr. Sangharatna Godboley, the founder of NITMiner Technologies Private Limited. As a Junior Software Engineer, I have actively contributed to this project by implementing the batch folder injection capabilities (which are extensively utilized and orchestrated within the `Final_sol.sh` script).**

# Solidity Assertion Coverage Analyzer

This project is a highly automated formal verification framework designed to analyze structural branch reachability and logic coverage in Solidity smart contracts. By instrumenting Solidity code dynamically, it helps mathematically prove which execution flows are reachable by leveraging the Solidity Compiler's built-in Model Checker (SMT Solver). 

This guide provides an architectural breakdown of the two focal scripts driving this engine: `Final_sol.sh` and `assertionInjector1.cpp`.

---

## 🏗️ Architecture & Core Analysis

### 1. The Orchestration Engine (`Final_sol.sh`)

`Final_sol.sh` is a robust Bash script serving as the primary automation and orchestration layer for the entire verification workflow. 

**Key Responsibilities and Logic:**
- **Dual Pipeline Execution:** Accepts user arguments to run structural verification using either Bounded Model Checking (`bmc`) or Constrained Horn Clauses (`chc`) via `solc`.
- **Recursive Folder Injection:** *([Contributed Feature])* Extends single-file evaluation into aggressive batch processing. It recursively traverses target directories using depth analysis to dynamically discover, collect, and process all `.sol` smart contracts within a project structure.
- **Assertion Delegation:** Orchestrates the injection mapping by feeding `.sol` copies into the underlying `.assertinserter` C++ binary, subsequently isolating the modified contracts in a sandboxed `Results/` backup directory.
- **Verification & Post-Processing:** Invokes `solc --model-checker-targets assert`. Once the solver throws deterministic warnings on reachability limits, the script utilizes extensive stream processing (`sed`, `grep`, `cut`, `sort`) to isolate "unique" vs "dynamic" assertion violations.
- **Automated Metric Reporting:** Calculates the **Condition Coverage %** based on how many atomic branches were successfully breached by the SMT solver, generating detailed timeline logs representing total computational overhead in seconds/minutes.

### 2. The Abstract Syntax Injector (`assertionInjector1.cpp`)

`assertionInjector1.cpp` is a localized C++ parsing engine responsible for parsing Solidity syntax, capturing branch conditions, and physically injecting reachability trackers directly into the abstract logic paths.

**Key Responsibilities and Logic:**
- **Dynamic Syntax Parsing:** Evaluates Solidity lines structurally without relying on a full compiler frontend. It looks for logical gateways primarily driven by `for`, `if`, `while`, and `require` statements.
- **Atomic Condition Splitting:** Deeply parses multi-faceted conditional operators (i.e. `&&`, `||`, `,`), effectively stripping them down into individual "atomic" statements to ensure hyper-granular branch tracking.
- **Dual Synthesis Check:** Once an atomic condition is detected, it runs the conditions through dual synthesizers:
  - `aseertSynthesier1` injects `assert(!(condition));`
  - `aseertSynthesier2` injects `assert(!(!(condition)));`
- **Reachability Paradigm:** The injected negative and double-negative bindings force the `solc` model checker into attempting to prove contradictory invariants. If the solver throws a "violation" upon verification, it effectively proves to the engineer that the branch logic is fundamentally reachable and executable without reverting.
- **Seamless Recompilation:** The tool automatically strips old assertions and overwrites `.sol` sources locally via temp-file rotation, emitting total payload sizes directly back to `Final_sol.sh` for calculating percentages.

---

## 🚀 Getting Started

### Prerequisites
- Bash Environment (Linux/macOS or WSL on Windows)
- `solc` (Solidity Compiler) installed globally in your `$PATH`.
- GCC Compiler (to compile `assertionInjector1.cpp` into the `.assertinserter` binary).

### Execution

Compile the C++ parser:
```bash
g++ assertionInjector1.cpp -o .assertinserter
```

Run the `Final_sol.sh` orchestrator with your target input (a single Solidity file, or a full repository folder) alongside the preferred verification engine (`bmc` or `chc`).

```bash
chmod +x Final_sol.sh
./Final_sol.sh <Target_Folder_or_Contract> bmc
```

The output will automatically generate isolated `Results/` mapping structural reachability against the test models.
