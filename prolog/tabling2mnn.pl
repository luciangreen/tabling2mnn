% tabling2mnn: turn tabled predicates into explicit memo tables (the MNN way) and compare. A
% memo table is a value passed along, so the code stays deterministic and the table can be
% inspected, saved and reused. Two examples: Fibonacci (each value computed once, not
% exponentially often) and reachability in a graph with cycles (a fixpoint, where plain
% recursion would loop).
%?- fib_memo(20, F, T), length(T, N).          % F = 6765, N = 21 table entries
%?- fib_calls(20, C).                          % C = 21891 calls without a table
%?- reach([a-b, b-c, c-a], R).                 % R = [a-a,a-b,a-c,b-a,...]: every pair, through the cycle
%?- reach_rounds([a-b, b-c, c-d], K).          % K = rounds until nothing new
:- module(tabling2mnn, [fib_naive/2, fib_calls/2, fib_memo/3, reach/2, reach_rounds/2, reach_bfs/3]).
:- use_module(library(lists)).
:- use_module(library(apply)).

fib_naive(N, F) :- ( N < 2 -> F = N ; A is N - 1, B is N - 2, fib_naive(A, FA), fib_naive(B, FB), F is FA + FB ).
fib_calls(N, C) :- ( N < 2 -> C = 1 ; A is N - 1, B is N - 2, fib_calls(A, CA), fib_calls(B, CB), C is CA + CB + 1 ).

% fib_memo(+N, -F, -Table): Table holds K-Fib(K) for every K =< N, filled once each.
fib_memo(N, F, T) :- fib_m(N, F, [], T0), msort(T0, T).
fib_m(N, F, T0, T) :- ( memberchk(N-F0, T0) -> F = F0, T = T0
    ; N < 2 -> F = N, T = [N-N|T0]
    ; A is N - 1, B is N - 2, fib_m(A, FA, T0, T1), fib_m(B, FB, T1, T2), F is FA + FB, T = [N-F|T2] ).

% reach(+Edges, -Pairs): every X-Y with a path of one or more edges, by fixpoint (semi-naive).
reach(Es, R) :- msort(Es, E0), sort(E0, Start), fix(Es, Start, Start, R, _).
fix(Es, All, New, R, K) :- findall(X-Z, ( member(X-Y, New), member(Y-Z, Es) ), C0), sort(C0, C), ord_subtract(C, All, Fresh),
    ( Fresh == [] -> R = All, K = 1 ; ord_union(All, Fresh, All1), fix(Es, All1, Fresh, R, K0), K is K0 + 1 ).
reach_rounds(Es, K) :- ( Es == [] -> K = 0 ; msort(Es, E0), sort(E0, S), fix(Es, S, S, _, K) ).

% reach_bfs(+Edges, +X, -Ys): what X reaches, by breadth-first search with a visited set (for checking).
reach_bfs(Es, X, Ys) :- findall(Y, member(X-Y, Es), F0), sort(F0, F), bfs(Es, F, F, Ys).
bfs(_, [], Seen, Seen).
bfs(Es, [N|Q], Seen, Ys) :- findall(M, ( member(N-M, Es), \+ memberchk(M, Seen) ), M0), sort(M0, Ms), ord_union(Seen, Ms, Seen1), append(Q, Ms, Q1), bfs(Es, Q1, Seen1, Ys).
