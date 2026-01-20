# Mini Compilateur OCaml

## Description
Ce projet consiste à implémenter un compilateur simple en OCaml, capable de traduire un langage impératif en assembleur MIPS. Le projet est découpé en différentes couches pour faciliter l’analyse, la traduction et la génération du code.

### Architecture du compilateur
- **Analyse lexicale** : `lexer.mll`
- **Analyse syntaxique** : `parser.mly`
- **Analyse sémantique et typage** : `semantics.ml`
- **Génération de code MIPS** : `compiler.ml`
- **Représentations (AST/IR)** : `ast.ml`
- **Point d’entrée** : `main.ml`
- **Représentation MIPS** : `mips.ml`

## Fonctionnalités du compilateur

### Types et représentations (AST / IR)
Le compilateur supporte les types suivants :
- `TInt` : Entiers
- `TBool` : Booléens
- `TString` : Chaînes de caractères

### Expressions supportées
- Constantes entières, booléennes, et chaînes
- Variables
- Appels de fonctions (builtins)

### Instructions prises en charge
- Déclaration de variables : `var x = expr;`
- Assignation : `x = expr;`
- Conditionnelle : `if expr { ... } else { ... }`
- Boucle : `while expr { ... }`
- Renvoi de valeur : `return expr;`
- Expression seule : `expr;`

### Bibliothèque de base (Baselib)
Le compilateur inclut des fonctions de bibliothèque de base pour les opérations arithmétiques, logiques, et d'entrée/sortie, comme :
- Opérations arithmétiques : `+`, `-`, `*`, `/`, `mod`
- Opérations logiques : `&&`, `||`, `xor`, `not`
- Comparaisons : `==`, `<`, `>`, `<=`
- Entrées/Sorties : `printi`, `printb`, `print_string`, `scani`, `scans`

## Installation

### Prérequis
- **OCaml** : La version recommandée est OCaml 4.12 ou supérieure.
- **Dune** : Outil de construction pour OCaml. Installe-le via `opam` si ce n'est pas déjà fait.

```bash
opam install dune
