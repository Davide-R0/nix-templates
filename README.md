# Nix-Templates

## Usage:

```bash  
mkdir nuovo-teorema
cd nuovo-teorema
#Usa l'alias definito nel registry 'my'
nix flake init -t my#lean    
```

## Come importarlo nella configurazione di nixos:

Per avere questi template disponibili su tutti gli host il metodo migliore è aggiungere la repo negli input del flake principale:

```nix
my-templates.url = "github:TuoUser/my-templates";
```

Poi nei moduli aggiungere (a chi lo vuole):

```nix
modules = [
  ({ ... }: {
    # Sincronizza il registry con l'input bloccato nel lockfile
    nix.registry.my.flake = my-templates;
  })
];
```

Oppure il metodo sconsigliato (aggiugnerlo al registry). In home-manager (o configuration.nix o flake.nix principale):

```nix
nix.registry = {
  # Alias 'my' (o 'templates', o il tuo nickname)
  my.to = {
    type = "github";
    owner = "TuoUsernameGitHub";
    repo = "my-nix-templates";
    # Opzionale: puoi pinnare un branch o tag
    # ref = "main"; 
  };
  # OPZIONE ALTERNATIVA (Se il repo dei template è locale o input del flake di sistema)
  # Se vuoi che i template siano sincronizzati ESATTAMENTE con quelli del tuo flake di sistema:
  # my.flake = inputs.my-templates;
};
```
