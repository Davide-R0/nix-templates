{
  description = "Ambiente di Analisi CERN ROOT + Jupyter + Python";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # Abilita software non-free se necessario (a volte serve per driver/cuda)
          config.allowUnfree = true;
        };

        # 1. Definiamo l'ambiente Python
        # Qui includiamo Jupyter e le librerie di analisi (numpy, pandas, etc.)
        # NOTA: ROOT non si installa via pip qui, ma lo prendiamo dal pacchetto di sistema.
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          jupyterlab
          notebook
          numpy
          pandas
          matplotlib
          scipy
          uproot  # Alternativa moderna a ROOT I/O puro
          awkward # Per gestire array irregolari (comune in HEP)
          ipympl  # Per plot interattivi in Jupyter
        ]);

        # 2. Il pacchetto ROOT configurato
        # Ci assicuriamo che abbia il supporto Python abilitato (di solito è default su unstable)
        rootPkg = pkgs.root.override {
          python3 = pkgs.python3;
        };

      in {
        devShells.default = pkgs.mkShell {
          name = "root-jupyter-env";

          buildInputs = [
            # Il Core
            rootPkg
            pythonEnv

            # Tool C++ (per compilare macro o librerie collegate a ROOT)
            pkgs.cmake
            pkgs.gcc      # o clang
            pkgs.gdb      # debugger
            pkgs.pkg-config
          ];
            
          # Impostiamo ROOTSYS puntando direttamente alla store path di ROOT
          ROOTSYS = "${rootPkg}";
          # Diciamo a Python dove trovare le librerie di ROOT (senza usare export nello script)
          # 'extraPythonPackages' è un esempio, ma per ROOT spesso basta aggiungere la lib al PYTHONPATH
          PYTHONPATH = "${rootPkg}/lib";
          # Per la compilazione C++ (opzionale ma utile per clang/gcc)
          CPLUS_INCLUDE_PATH = "${rootPkg}/include";

          # Variabili d'ambiente per far trovare ROOT a Jupyter e al compilatore
          shellHook = ''
            # Codici colori
            GREEN='\033[0;32m'
            NC='\033[0m'

            echo -e "''${GREEN}"
            echo "   ---------------------------------------------------"
            echo "   ⚛️  CERN ROOT Analysis Environment Loaded"
            echo "   ---------------------------------------------------"
            echo "   ROOT Version: $(root-config --version)"
            echo "   Python:       $(python --version)"
            echo "   Jupyter:      Ready (run 'jupyter lab')"
            echo -e "''${NC}"
          '';
        };
      }
    );
}
