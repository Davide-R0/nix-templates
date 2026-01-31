# Nix-Templates

## Usage

```bash  
mkdir nuovo-teorema
cd nuovo-teorema
#Usa l'alias definito nel registry 'my'
nix flake init -t my#lean    
```

## Come importarlo nella configurazione di nixos

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

