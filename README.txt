Projet : Programmation d’un mini-compilateur
L3 Informatique — 2025/2026
Interprétation et compilation — Pablo Rauzy

Étudiante : Bathily Mariame
Numéro étudiant : 22000987
Groupe : L3-A

--- README.txt ---

1- Présentation
Ce projet consiste à réaliser un compilateur pour un langage impératif simple, traduisant un code source vers de
l’assembleur MIPS. L’architecture suit une méthodologie par couches :
    - Analyse lexicale : lexer.mll
    - Analyse syntaxique : parser.mly
    - Analyse sémantique / typage + traduction vers IR : semantics.ml
    - Génération de code MIPS : compiler.ml (+ baselib.ml)
    - Représentations (AST/IR) : ast.ml
    - Point d’entrée : main.ml
    - Représentation MIPS : mips.ml


2- Fonctionnalités du compilateur

2.1 Types et représentations (AST / IR)
Types de base :
    - TInt : entiers
    - TBool : booléens
    - TString: chaînes de caractères

Expressions prises en charge :
    - constantes entières, booléennes et chaînes
    - variables
    - appels de fonctions (builtins)

Instructions prises en charge :
    - déclaration de variable : var x = expr;
    - assignation : x = expr;
    - conditionnelle : if expr { ... } else { ... }
    - boucle : while expr { ... }
    - renvoi de valeur : return expr;
    - expression seule : expr;

Blocs :
    - les blocs sont des séquences d’instructions
    

2.2 Bibliothèque de base (Baselib)
Opérations arithmétiques :
   - +, -, *, /, mod

Opérations logiques :
   - && (and), || (or), xor, not

Comparaisons :
   - == (eq)
   - <  (lt)
   - >  (gt)
   - <= (le)

Entrées / sorties :
   - printi(expr) : affiche un entier
   - printb(expr) : affiche un booléen ("true"/"false")
   - print_string(expr) : affiche une chaîne
   - scani : lit un entier au clavier
   - scans : lit une chaîne au clavier


3- Gestion des erreurs

Le compilateur détecte et signale :
    - les erreurs lexicales
    - les erreurs syntaxiques
    - les erreurs sémantiques (typage, variable inconnue, fonction inconnue, etc.)

Les messages d’erreur incluent la position de l’erreur (ligne/colonne).


4- Gestion mémoire
Prologue :
    - sauvegarde de $ra et $fp sur la pile
    - initialisation du pointeur de cadre ($fp)

Épilogue / nettoyage :
    - la remise à zéro de l’espace local se fait via "move $sp, $fp" à la fin de l’exécution, ou lors d’un "return"

5- Syntaxe et usage
La syntaxe est de type C.
Les fonctions (printi/printb/print_string, scani, etc.) sont gérées via des appels définies dans baselib.

Remarque sur les priorités :
    - les priorités d’opérateurs ne sont pas définies finement dans la grammaire. il faut utiliser des parenthèses pour lever toute ambiguïté (ex : (1 + 2) * 3).


6- Compilation et tests

Pour compiler et lancer un test:

dune build main.exe && ./_build/default/main.exe tests/nom_du_fichier.test > sortie.s && spim -file sortie.s

Organisation des tests :
    - fichiers standards (ex : add.test, xor.test, call.test, while.test) : compilation et exécution attendues
    - fichiers préfixés par 'err-' (ex : err-type.test) : validation de la détection d’erreurs sémantiques