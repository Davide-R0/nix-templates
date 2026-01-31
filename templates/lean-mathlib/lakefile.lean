import Lake
open Lake DSL

package "MyProject" where
  version := v!"0.1.0"
  keywords := #["math"]
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩, -- pretty-prints `fun a ↦ b`
    ⟨`relaxedAutoImplicit, false⟩,
    ⟨`maxSynthPendingDepth, .ofNat 3⟩,
    ⟨`weak.linter.mathlibStandardSet, true⟩,
  ]

require "leanprover-community" / "mathlib"

@[default_target]
lean_lib «MyProject» where
  -- add any library configuration options here


-- `lake exe repl`
@[default_target]
lean_exe «Main» where
  root := `Main

-- Sandbox directory
lean_lib «Sandbox» where
  roots := #[`Sandbox]
