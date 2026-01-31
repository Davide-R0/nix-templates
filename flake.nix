{
  description = "Collezione di template Nix personali";
  
  outputs = { self }: {
    
    templates = {
      lean = {
        path = ./templates/lean-mathlib;
        description = "Ambiente Lean 4 con Mathlib, Cache e Doc-gen4";
        
        welcomeText = ''
          ================================================================
          Ambiente Lean 4 inizializzato!
          
          Passi successivi:
          1. git init (Se non sei già in un repo, fondamentale per i Flake!)
          2. Modifica 'lakefile.lean' cambiando il nome del pacchetto.
          3. Modifica 'flake.nix' cambiando 'name = "..."' per coerenza.
          4. git add .
          5. nix develop o direnv allow
          ================================================================
        '';
      };
      
      rust = {
        path = ./templates/rust;
        description = "Rust Toolchain (via Oxalica Overlay)";
        
        welcomeText = ''
          🦀 Ambiente Rust inizializzato!
          
          Include: rustc, cargo, rust-analyzer, openssl e pkg-config.
          Ricordati di fare 'git init' e 'git add .'
        '';
      };

      root-analysis = {
        path = ./templates/research-root-notebook;
        description = "CERN ROOT + JupyterLab + NumPy Stack";
        welcomeText = ''
          ⚛️ Ambiente ROOT inizializzato.
          Lancia 'nix develop' e poi 'jupyter lab' per iniziare.
          Include supporto per PyROOT e compilazione C++.
        '';
      };
      # Puoi aggiungerne altri qui (es. python, rust, c++, etc.)
    };

    # Imposta questo come template di default se non specifichi nulla
    #defaultTemplate = self.templates.lean;
  };
}
