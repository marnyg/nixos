{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.langs.quint;

  quint-language-server = pkgs.callPackage ./quint-language-server.nix { };

  # Neither nvim-treesitter nor nixpkgs ship a Quint grammar. The community
  # grammar keeps the generated parser out of `master` to avoid build
  # artifacts, so we pin the `release` branch which has `src/parser.c`
  # pre-generated (and therefore needs no `generate = true`).
  treesitter-quint-grammar = pkgs.tree-sitter.buildGrammar {
    language = "quint";
    version = "0-unstable-2026-05-04";
    src = pkgs.fetchFromGitHub {
      owner = "gruhn";
      repo = "tree-sitter-quint";
      rev = "e413b1b57849a0097478548b25fcae2f3d0171d1";
      hash = "sha256-WVSRFaj+X/S4DgyA6nWmRO+99iWG9Tr5hVrj53VB8E4=";
    };
    meta.homepage = "https://github.com/gruhn/tree-sitter-quint";
  };
in
{
  options.langs.quint = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Quint (formal specification language) support.";
    };
    lsp.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable LSP server.";
    };
    cli.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Put the `quint` CLI (typechecker, simulator, verifier) on Neovim's PATH.";
    };
  };

  config = mkIf cfg.enable {
    # Neovim has no built-in filetype detection for `.qnt`.
    filetype.extension.qnt = "quint";

    extraPackages = mkIf cfg.cli.enable [ pkgs.quint ];

    lsp.servers.quint = mkIf cfg.lsp.enable {
      enable = true;
      package = quint-language-server;
      config = {
        cmd = [ "quint-language-server" "--stdio" ];
        filetypes = [ "quint" ];
        root_markers = [ ".git" ];
      };
    };

    plugins.treesitter = {
      grammarPackages = [ treesitter-quint-grammar ];
      # Grammar name and filetype already agree ("quint"), so no
      # `languageRegister` entry is needed.
    };
  };
}
