:- module(cases, [title/1, case/3]).
:- use_module('../prolog/tabling2mnn').
:- use_module(engine).
title('tabling2mnn').
graph_g(Es) :- rnd_int(0, 6, N), length(Es, N), maplist([X-Y]>>( rnd_pick([a, b, c, d, e], X), rnd_pick([a, b, c, d, e], Y) ), Es).
case(fib_memo, [N], fib_memo_size) :- rnd_int(0, 40, N).
case(fib_calls, [N], fib_calls) :- rnd_int(0, 20, N).
case(reach, [Es], reach) :- graph_g(Es).
case(reach_rounds, [Es], reach_rounds) :- graph_g(Es).
case(reach_bfs, [Es, X], reach_bfs) :- graph_g(Es), rnd_pick([a, b, c], X).
fib_memo_size(N, F-entries(K)) :- fib_memo(N, F, T), length(T, K).
