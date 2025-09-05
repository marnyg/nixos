# Projects

This directory contains all personal projects managed within this NixOS monorepo. Each project has its own flake-parts module for local scoping and development environment.

## Active Projects

### nixvim

**Location:** `projects/nixvim/`  
**Description:** Custom Neovim distribution built with nixvim  
**Dev Shell:** `nix develop .#nixvim`  
**Package:** `nix build .#nixvim`

### agentic-dm

**Location:** `projects/agentic-dm/`  
**Description:** AI-powered Dungeon Master assistant for tabletop RPGs  
**Tech Stack:** Elixir, PostgreSQL  
**Dev Shell:** `nix develop .#agentic-dm`  
**Commands:**

- `mix deps.get` - Install dependencies
- `mix ecto.create` - Create database
- `mix ecto.migrate` - Run migrations
- `iex -S mix` - Interactive shell

### postgres-auditing

**Location:** `projects/postgres-auditing/`  
**Description:** PostgreSQL auditing tools and utilities  
**Status:** Planning phase

### proc-compose-example

**Location:** `projects/proc-compose-example/`  
**Description:** Example of process composition patterns in Nix  
**Status:** Example/reference implementation

## Experimental Projects

### radRePomodora

**Location:** `projects/experimental/radRePomodora/`  
**Description:** Pomodoro timer implementation  
**Tech Stack:** OCaml  
**Status:** Experimental

### scheduler

**Location:** `projects/experimental/scheduler/`  
**Description:** Task scheduling experiments  
**Status:** Early exploration

## Project Structure

Each project follows this structure:

```
project-name/
├── default.nix    # Flake-parts module definition
├── README.md      # Project-specific documentation
└── ...           # Project source files
```

## Adding a New Project

1. Create a new directory under `projects/`:

```bash
mkdir projects/my-project
```

2. Create a `default.nix` with the flake-parts module:

```nix
# projects/my-project/default.nix
{ inputs, ... }: {
  perSystem = { pkgs, config, ... }: {
    # Define packages
    packages.my-project = pkgs.callPackage ./package.nix { };

    # Define development shell
    devShells.my-project = pkgs.mkShell {
      name = "my-project";
      packages = with pkgs; [ ];
      shellHook = ''
        echo "My Project Development Environment"
      '';
    };
  };
}
```

3. Import it in `projects/default.nix`:

```nix
{
  imports = [
    ./my-project
    # ... other projects
  ];
}
```

## Development Workflow

### Enter a project's development environment:

```bash
nix develop .#<project-name>
```

### Build a project:

```bash
nix build .#<project-name>
```

### Run project tests:

```bash
nix flake check
```

## Benefits of Monorepo Structure

- **Unified tooling**: All projects share the same Nix infrastructure, formatters, and CI
- **Cross-project dependencies**: Projects can easily depend on each other
- **Atomic commits**: System configuration and project changes can be committed together
- **Consistent environments**: Development environments are reproducible across all projects

## Continuous Integration

Projects are automatically tested when running:

```bash
nix flake check
```

This runs all defined checks for all projects.
