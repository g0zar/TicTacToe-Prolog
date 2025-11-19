% License: CC0 (Public Domain)

:- include('main.pro').



% auxiliary file to test behavior of varios
% predicates

test_victory(Sn):-
	S = play_area(
	f(1),f(2),f(0),
	f(0),f(0),f(0),
	f(0),f(0),f(0)),
	copy_term(S, Sn),
	% find victory move of opposing player
	(find_victory_move(Sn, IDX),
	% replace with our move
	setarg(IDX, Sn, f(2)) ; writeln('no victory move')),
	% if no such move is found
	% 	backtrack? from a possible winning move
	display_state(Sn).

test_plan_ahead(Sfinal):-
	S = play_area(
	f(1),f(2),f(1),
	f(1),f(2),f(0),
	f(2),f(0),f(1)),
	%trace,
	plan_moves(S, Sn, Sfinal, 0, _),
	writeln('next:'),
	display_state(Sn),
	writeln('final:'),
	display_state(Sfinal).


test_plan_ahead_shortest(R):-
	S = play_area(
	f(1),f(2),f(1),
	f(1),f(0),f(0),
	f(2),f(0),f(0)),
	plan_ahead_shortest(S, R),
	Sn = S,
	nth(1,R,V), setarg(V, Sn, f(2)),
	display_state(Sn).

test_plan_ahead_center_pref(R):-
	S = play_area(
	f(1),f(2),f(1),
	f(1),f(0),f(0),
	f(2),f(0),f(0)),
	plan_ahead_center_preference(S, R),
	Sn = S,
	(R \= [] -> setarg(5, Sn, f(2)) ; 
		nth(1,R,V), setarg(V, Sn, f(2))),
	display_state(Sn).

test_plan(R):-
	S = play_area(
	f(1),f(2),f(0),
	f(0),f(0),f(1),
	f(2),f(0),f(1)),
	(plan_ahead_center_preference(S, R);
	plan_ahead_shortest(S, R)).

test_false_draw:-
	S = play_area(
	f(1),f(2),f(2),
	f(0),f(2),f(1),
	f(1),f(1),f(0)),
	% com on the move
	com_move(S, Sn), display_board(Sn).
	

test_com_move:-
	S = play_area(
	f(1),f(2),f(1),
	f(1),f(2),f(0),
	f(2),f(0),f(1)),
	com_move(S, Sn),
	display_state(Sn).


input_handler(X):-
	repeat, write('int:'),flush_output, read_token(X), member(X, [1,2,3]).

test_exp:-
	input_handler(INT), writeln(INT).

