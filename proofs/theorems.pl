% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/tabling2mnn').

% Domain: Fibonacci of 0..18; every directed graph on nodes a, b, c (all 512 edge sets).
graph(Es) :- findall(X-Y, ( member(X, [a, b, c]), member(Y, [a, b, c]) ), All), subset_of(All, Es).
subset_of([], []).
subset_of([X|Xs], [X|Ys]) :- subset_of(Xs, Ys).
subset_of([_|Xs], Ys) :- subset_of(Xs, Ys).

% 1. The memo table gives the same Fibonacci numbers as plain recursion.
theorem(memo_equals_naive) :- forall(between(0, 18, N), ( fib_memo(N, F, _), fib_naive(N, G), F =:= G )).

% 2. The table has exactly one entry per K =< N (for N >= 2: below that only the base case is needed), and each is right.
theorem(table_entries_once_each) :- forall(between(2, 18, N), ( fib_memo(N, _, T), N1 is N + 1, length(T, N1), forall(member(K-F, T), fib_naive(K, F)) )).

% 3. Without a table the calls grow much faster than the N + 1 entries (more than double from N = 5 on).
theorem(table_saves_calls) :- forall(between(5, 18, N), ( fib_calls(N, C), C > 2 * (N + 1) )).

% 4. The fixpoint finds exactly the pairs breadth-first search does, on every graph, cycles included.
theorem(fixpoint_equals_search) :- forall(graph(Es), ( reach(Es, R), forall(member(X, [a, b, c]), ( reach_bfs(Es, X, Ys), findall(Y, member(X-Y, R), Zs), Zs == Ys )) )).

% 5. The fixpoint ends within as many rounds as there are nodes.
theorem(fixpoint_ends_quickly) :- forall(graph(Es), ( reach_rounds(Es, K), K =< 3 )).
