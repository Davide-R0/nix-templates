{
  description = "Ambiente di sviluppo Rust (Zero Rustup)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Questo overlay ci fornisce le versioni di rust selezionabili
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay, ... }: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    devShells = forAllSystems (system: let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };
      
      # === CONFIGURAZIONE TOOLCHAIN ===
      # Qui scegli la versione. Esempi:
      # - pkgs.rust-bin.stable.latest.default
      # - pkgs.rust-bin.nightly."2024-01-01".default
      # - pkgs.rust-bin.stable."1.75.0".default
      rustToolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" ];
      };

    in {
      default = pkgs.mkShell {
        buildInputs = [
          rustToolchain
          
          # Dipendenze comuni che servono quasi sempre in Rust
          pkgs.openssl
          pkgs.pkg-config # Cruciale per trovare le librerie C
        ];

        # Variabili d'ambiente utili
        RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
        
        shellHook = ''
           echo "🦀 Rust Environment Loaded"
           echo "Version: $(rustc --version)"
        '';
      };
    });
  };
}
