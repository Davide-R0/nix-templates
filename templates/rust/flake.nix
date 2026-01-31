{
  description = "Ambiente di sviluppo Rust";

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
      # Qui scegliamo la versione.
      # Opzione A: Ultima Stable (aggiornata automaticamente)
      # rustToolchain = pkgs.rust-bin.stable.latest.default;
      
      # Opzione B: Una versione specifica (per riproducibilità)
      # rustToolchain = pkgs.rust-bin.stable."1.75.0".default;

      # Opzione C (LA MIGLIORE): Legge il file rust-toolchain.toml del progetto!
      # Così collabori con chi usa rustup senza problemi.
      rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
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
