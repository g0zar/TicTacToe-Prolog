% License: CC0 (Public Domain)

% initalization goal for compilation via gplc
:- initialization(main).

% player 1 and player 2 predicates
p(1).
p(2).

% --- win conditions ---
% we define all the patterns that produce a victory
board(play_area(
	f(X),f(X),f(X),
	f(_),f(_),f(_),
	f(_),f(_),f(_))):-
		p(X).

board(play_area(
	f(_),f(_),f(_),
	f(X),f(X),f(X),
	f(_),f(_),f(_))):-
		p(X).

board(play_area(
	f(_),f(_),f(_),
	f(_),f(_),f(_),
	f(X),f(X),f(X))):-
		p(X).

board(play_area(
	f(X),f(_),f(_),
	f(X),f(_),f(_),
	f(X),f(_),f(_))):-
		p(X).

board(play_area(
	f(_),f(X),f(_),
	f(_),f(X),f(_),
	f(_),f(X),f(_))):-
		p(X).

board(play_area(
	f(_),f(_),f(X),
	f(_),f(_),f(X),
	f(_),f(_),f(X))):-
		p(X).

board(play_area(
	f(X),f(_),f(_),
	f(_),f(X),f(_),
	f(_),f(_),f(X))):-
		p(X).

board(play_area(
	f(_),f(_),f(X),
	f(_),f(X),f(_),
	f(X),f(_),f(_))):-
		p(X).

% ================


% find an empty field f(0) in the playing board
find_empty(S, IDX):-
	between(1,9,IDX),
	arg(IDX, S, f(0)).

find_victory_move(S, IDX):-
	copy_term(S, Sn),
	find_empty(S, IDX),
	setarg(IDX, Sn, f(1)),
	board(Sn).

% finds solutions to victory
% used in plan_ahead_shortest to find shortest
% winning strategy
plan_moves(S, Sfinal, MAX, L, OL, R):-
	MAX < 5,
	copy_term(S, Sn),
	find_empty(S, IDX),
	setarg(IDX, Sn, f(2)),
	append(L, [IDX], OL),
	% board(Sn) essentially checks for a winning board configuration
	(board(Sn) -> Sfinal = Sn, R = OL;
		Nmax is MAX + 1,
		plan_moves(Sn, Sfinal, Nmax, OL, _, R)).

% helper predicate to make a new fresh board
new_state(S):-
	S = play_area(f(0),f(0),f(0), f(0),f(0),f(0), f(0),f(0),f(0)).

display_state(S):-
	arg(1, S, F1),
	arg(2, S, F2),
	arg(3, S, F3),
	writeln([F1,F2,F3]),
	arg(4, S, F4),
	arg(5, S, F5),
	arg(6, S, F6),
	writeln([F4,F5,F6]),
	arg(7, S, F7),
	arg(8, S, F8),
	arg(9, S, F9),
	writeln([F7,F8,F9]).

% symbol predicates for pretty printing
sym(f(1), 'X').
sym(f(2), 'O').
sym(f(0), ' ').

% pretty print tic tac toe board
display_board(S):-
	format('   1 2 3~n',[]),
	arg(1, S, F1), sym(F1, C1),
	arg(2, S, F2), sym(F2, C2),
	arg(3, S, F3), sym(F3, C3),
	format('1 |~a|~a|~a|~n', [C1,C2,C3]),
	arg(4, S, F4), sym(F4, C4),
	arg(5, S, F5), sym(F5, C5),
	arg(6, S, F6), sym(F6, C6),
	format('2 |~a|~a|~a|~n', [C4,C5,C6]),
	arg(7, S, F7), sym(F7, C7),
	arg(8, S, F8), sym(F8, C8),
	arg(9, S, F9), sym(F9, C9),
	format('3 |~a|~a|~a|~n', [C7,C8,C9]).

% read loop until player enters a token which is either 1 2 or 3
% for both the row and column. If either fails, it rewids back to the
% repeat statement and starts over.
read_user_input(Row, Col):-
	repeat, 
	writeln('Enter a number between 1 and 3 for both row and column.'),
	write('row:'), flush_output, read_token(Row),
		(member(Row, [1,2,3]) ; fail),
	write('col:'), flush_output, read_token(Col),
		(member(Col, [1,2,3]) ; fail).

% user input processing
user_input(S,Sn):-
	read_user_input(In_ROW, In_COL),
	% calculates offset into the board, which is a simple linear
	% array, so we do some calculations to get the right offsets
	% for the row and columns
	IDX is ((In_ROW - 1) * 3) + In_COL,
	Sn = S,
	arg(IDX, S, f(A)), (A = 0 ; writeln('Field isn\'t empty'), fail), % ensure the selected field is empty.
	setarg(IDX, Sn, f(1)).


% helper function for writing with newline
writeln(A):- write(A), write('\n').

% find shortest solution to victory
plan_ahead_shortest(S, R):-
	% find all possible moves for Com. Generates a list
	% of list with indexes indicating the order of moves
	% to make to score a victory
	findall(C, plan_moves(S, _, 0, [], _, C), C),
	% map a new list of lengths of the solutions
	maplist(length, C, Lengths),
	% get the lowest number M in the list, indicating
	% shortest solution
	min_list(Lengths, M),
	% get the index N of the first occurece of number M
	nth(N, Lengths, M),
	% use the same index to select the strategy in the
	% original list of solutions
	nth(N, C, R).

% simple helper function to find a list within a list
% that contains the number 5
list_with_center(LL, L):-
	member(L, LL), member(5, L).

% same as previous plan, except it filters
% all solutions through the helper function,
% making sure the new solutions all contain a center
% field as part of the winning strategy
plan_ahead_center_preference(S, R):-
	findall(C, plan_moves(S, _, 0, [], _, C), C),
	findall(O, list_with_center(C, O), CC),
	maplist(length, CC, Lengths),
	min_list(Lengths, M),
	nth(N, Lengths, M),
	nth(N, CC, R).

% Computer oponent logic
com_move(S, Sn):-
	% EITHER:
	% find victory move of opponent and prevent the victory by setting the field ourselves
	find_victory_move(S, IDX), Sn = S, setarg(IDX, Sn, f(2))
	% OR
	;
	% find a winning strategy with a center field preference and set the field
	plan_ahead_center_preference(S, _), Sn = S, setarg(5, Sn, f(2))
	% OR
	;
	% find the shortest winning strategy and set the field
	plan_ahead_shortest(S, R), Sn = S, nth(1,R,V), setarg(V, Sn, f(2)).


% predicate to process user input
player_turn(S, Sn):-
	% handle user input, creates new state Sn
	user_input(S, Sn),
	% check if input from player actually causes a win condition
	(board(Sn), display_board(Sn), writeln('Player wins'), halt; true).

com_turn(S, Sn):-
	% Com makes a move and if its a winning move, display the board and end game
	com_move(S, Sn), board(Sn), display_board(Sn), writeln('Com wins'), halt ;
	% OR, make a move and return the updated board in Sn
	(com_move(S, Sn) ;
		% OR, if com cant make a valid/sensible move, declare a draw
		writeln('Draw'), display_board(S), halt).

% turn order 1 = player goes first
turn_order(1, S, Snn):-
	display_board(S),
	player_turn(S, Sn),
	com_turn(Sn, Snn).

% turn order 2 = com goes first
turn_order(2, S, Snn):-
	com_turn(S, Sn),
	display_board(S),
	find_empty(Sn, _),
	player_turn(Sn, Snn).

% user RF which is a random float, to determine who goes first
pick_random_turn_order(RF, S, Sn):-
	RF > 0.5, turn_order(1, S, Sn) ; turn_order(2, S, Sn).

% main loop
game_loop(RF, S):-
	pick_random_turn_order(RF, S, Sn),
	game_loop(RF, Sn). % calls the loop again with new state

% main entry point
main:-
	randomize, % initialize the random seed
	new_state(S), % construct a new state
	random(RF), % generate a random number
	% check who goes first, same as pick_random_turn_order but just
	% prints a message to inform the user
	(RF > 0.5, writeln('Player turn start') ; writeln('Com turn start')),
	game_loop(RF,S), % start the game loop
	halt. % should never end up here, but in case we do, halt the program.

