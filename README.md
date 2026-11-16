# tabling2mnn

turn tabled predicates into explicit memo tables (the MNN way) and compare. A memo table is a value passed along, so the code stays deterministic and the table can be inspected, saved and reused. Two examples: Fibonacci (each value computed once, not exponentially often) and reachability in a graph with cycles (a fixpoint, where plain recursion would loop).

## Use

```prolog
?- use_module(prolog/tabling2mnn).
?- fib_memo(20, F, T), length(T, N).          % F = 6765, N = 21 table entries
?- fib_calls(20, C).                          % C = 21891 calls without a table
?- reach([a-b, b-c, c-a], R).                 % R = [a-a,a-b,a-c,b-a,...]: every pair, through the cycle
?- reach_rounds([a-b, b-c, c-d], K).          % K = rounds until nothing new
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. Fibonacci of 0..18; every directed graph on nodes a, b, c (all 512 edge sets).

1. The memo table gives the same Fibonacci numbers as plain recursion.
2. The table has exactly one entry per K =< N (for N >= 2: below that only the base case is needed), and each is right.
3. Without a table the calls grow much faster than the N + 1 entries (more than double from N = 5 on).
4. The fixpoint finds exactly the pairs breadth-first search does, on every graph, cycles included.
5. The fixpoint ends within as many rounds as there are nodes.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
