{
  description = "Mio Progetto Lean con Mathlib e Doc-gen4";
  # Al posto di fare lake update: `nix flake update` e non c'è bisogno di scaricare le cahce, lo fa in automatico. Per il resto il flusso di lavoro è uguale.
  # NOTA: nel lakefile lasciarlo vuoto senza versioni di lean, solo nel lean-toolchain mettere la stessa versione di lean che c'è nel flake.nix

  # Cache: Mettile qui per comodità degli utenti Nix che clonano il repo.
  # Nix chiederà conferma per usarle la prima volta.
  nixConfig = {
    # NOTE: sono giuste queste cache?
    extra-substituters = [
      "https://lean4.cachix.org/"
      "https://doc-gen4.cachix.org/"
    ];
    extra-trusted-public-keys = [
      "lean4.cachix.org-1:mawtxSxcaiG8fYS27hgh2bhzNE8Oz8j84UhFV9RLQ/s="
      "doc-gen4.cachix.org-1:ntt7k+lX6nLGG71Z8s/5qXo4j9p9KjA600+t3p6c7bM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Serve per utility generali

    # 1. Mathlib è la "Source of Truth".
    # Usiamo mathlib per definire la versione di Lean, così usiamo la sua cache.
    mathlib.url = "github:leanprover-community/mathlib4/v4.27.0"; # NOTE: lean version
    # 2. Forziamo l'input 'lean' ad essere QUELLO usato da mathlib.
    lean.follows = "mathlib/lean";  #nix run .#lean -- --version
    # 3. Anche doc-gen4 deve usare lo stesso Lean di mathlib per funzionare.
    doc-gen4 = {
      url = "github:leanprover/doc-gen4";
      inputs.lean.follows = "mathlib/lean";
    }
  };

  outputs = { self, nixpkgs, lean, mathlib, doc-gen4, ... }: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = lean.lib.genAttrs supportedSystems; # Helper standard
  in {
    packages = forAllSystems (system: let
      # Il pacchetto del tuo progetto
      # buildLeanPackage si occupa di compilare il tuo codice + dipendenze
      pkg = lean.packages.${system}.buildLeanPackage {
        name = "MioProgetto"; # Deve corrispondere al nome nel lakefile.lean
        src = ./.; 
        
        # Aggiungiamo le dipendenze al contesto di build
        # Nota: Normalmente Lake le gestisce, ma qui possiamo iniettarle se necessario
        # o lasciare che buildLeanPackage legga il lakefile se configurato bene.
      };
    in {
      default = pkg.executable;
      # Esponi anche la libreria se serve
      inherit (pkg) modRoot sharedLib;
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      leanPkgs = lean.packages.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = [
          leanPkgs.lean-all # Include lean, lake, leanc, etc.
          pkgs.python3 # For doc-gen4 
          pkgs.figlet # For terminal ascii
          pkgs.lolcat # For terminal
          # Qui potresti aggiungere tool extra come script python ecc.
        ];

        # Variabili d'ambiente essenziali affinché Lake trovi le librerie Nix
        LEAN_PATH = "${mathlib.packages.${system}.mathlib}/lib/lean";
        LEAN_SRC_PATH = "${mathlib.packages.${system}.mathlib}/lib/lean/src";

        shellHook = ''
          BLUE='\033[0;34m'
          CYAN='\033[0;36m'
          NC='\033[0m' # No Color

          echo -e "''${BLUE}"
          echo "    \\\\  \\\\ //"
          echo "   \\\\\\\\  \\\\ //   ''${CYAN}Lean 4 Development Environment''${BLUE}"
          echo "    \\\\\\\\//\\\\ //    "
          echo "     \\\\ //\\\\//     ''${NC}Project: ''${CYAN}MyMathProject''${NC}"
          echo -e "''${BLUE}    //\\\\//\\\\\\\\     "
          echo "   //  \\\\\\\\  \\\\    ''${NC}Lean Version: $(lean --version | cut -d ' ' -f 3)"
          echo "  //    \\\\\\\\  \\\\   ''${NC}System: ''${CYAN}${system}''${NC}"
          echo -e "''${BLUE} //      \\\\\\\\  \\\\  ''${NC}"
          echo ""

          figlet -f slant "Lean 4 Env" | lolcat
          echo "Environment loaded via Flake."
        '';
      };
    });
    
    # To matain the lean-toolchain updated
    apps = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      update-toolchain = {
        type = "app";
        program = toString (pkgs.writeShellScript "update-toolchain" ''
          # Estrae la versione esatta di Lean dal pacchetto Nix
          LEAN_VERSION=$(${lean.packages.${system}.lean}/bin/lean --version | awk '{print $3}' | sed 's/,//')
          
          echo "Aggiorno lean-toolchain alla versione: $LEAN_VERSION"
          echo "leanprover/lean4:$LEAN_VERSION" > lean-toolchain
          
          echo "Fatto."
        '');
      };
    });
  };
}
