% ==========================================
% JOGO DA VELHA EM PROLOG
% ==========================================

:- dynamic jogada/3.

% Definido explicitamente as posições válidas do tabuleiro
posicao(1).
posicao(2).
posicao(3).

% ------------------------------------------
% 1. ESTADO INICIAL
% ------------------------------------------
iniciar :-
    retractall(jogada(_, _, _)), %Pode remover múltiplas claúsulas e regras simultaneamente
    write('Bem-vindo ao Jogo da Velha!'), nl,
    write('Tu és o "x" e eu sou o "o".'), nl,
    imprimir_tabuleiro,
    turno_jogador.

% ------------------------------------------
% 2. REGRAS DE VITÓRIA E EMPATE
% ------------------------------------------
vencedor(J) :- jogada(L, 1, J), jogada(L, 2, J), jogada(L, 3, J). 
vencedor(J) :- jogada(1, C, J), jogada(2, C, J), jogada(3, C, J). 
vencedor(J) :- jogada(1, 1, J), jogada(2, 2, J), jogada(3, 3, J). 
vencedor(J) :- jogada(1, 3, J), jogada(2, 2, J), jogada(3, 1, J). 

% O empate só ocorre se NÃO houver nenhuma posição livre VÁLIDA
empate :- \+ livre(_, _).

% ------------------------------------------
% 3. REGRAS NÃO TRIVIAIS (IA)
% ------------------------------------------
diagonal_principal(1, 1). diagonal_principal(2, 2). diagonal_principal(3, 3).
diagonal_secundaria(1, 3). diagonal_secundaria(2, 2). diagonal_secundaria(3, 1).

falta_um(J, L, C) :- 
    posicao(L), posicao(C), % Garante que só procura no tabuleiro 3x3
    jogada(L, C1, J), jogada(L, C2, J), C1 \= C2, 
    posicao(C), C \= C1, C \= C2, livre(L, C).
falta_um(J, L, C) :- 
    posicao(L), posicao(C),
    jogada(L1, C, J), jogada(L2, C, J), L1 \= L2, 
    posicao(L), L \= L1, L \= L2, livre(L, C).
falta_um(J, L, C) :- 
    diagonal_principal(L1, C1), diagonal_principal(L2, C2), L1 \= L2, 
    jogada(L1, C1, J), jogada(L2, C2, J), 
    diagonal_principal(L, C), L \= L1, L \= L2, livre(L, C).
falta_um(J, L, C) :- 
    diagonal_secundaria(L1, C1), diagonal_secundaria(L2, C2), L1 \= L2, 
    jogada(L1, C1, J), jogada(L2, C2, J), 
    diagonal_secundaria(L, C), L \= L1, L \= L2, livre(L, C).

escolher_jogada(L, C) :- falta_um(o, L, C), !. 
escolher_jogada(L, C) :- falta_um(x, L, C), !. 
escolher_jogada(2, 2) :- livre(2, 2), !.       
escolher_jogada(L, C) :- member((L,C), [(1,1), (1,3), (3,1), (3,3)]), livre(L, C), !.
escolher_jogada(L, C) :- member((L,C), [(1,2), (2,1), (2,3), (3,2)]), livre(L, C), !.

% ------------------------------------------
% 4. CICLO DE TURNOS
% ------------------------------------------
% Uma posição só é livre se for de 1 a 3 e NÃO estiver ocupada
livre(L, C) :- posicao(L), posicao(C), \+ jogada(L, C, _).

turno_jogador :-
    write('Tua vez (x). Linha (1-3): '), read(L),
    write('Coluna (1-3): '), read(C),
    (   livre(L, C)
    ->  assertz(jogada(L, C, x)), 
        imprimir_tabuleiro,
        verificar_estado(x, turno_computador)
    ;   write('Posicao invalida! Tenta de novo.'), nl,
        turno_jogador
    ).

turno_computador :-
    write('A minha vez (o)...'), nl,
    escolher_jogada(L, C),
    assertz(jogada(L, C, o)), %Adiciona uma claúsula, fato ou regra, no final da base de dados
    imprimir_tabuleiro,
    verificar_estado(o, turno_jogador).

verificar_estado(J, _) :-
    vencedor(J),
    write('Temos um vencedor! Parabens: '), write(J), nl, !.
verificar_estado(_, _) :-
    empate,
    write('O jogo empatou!'), nl, !.
verificar_estado(_, ProximoTurno) :-
    call(ProximoTurno). 

% ------------------------------------------
% 5. INTERFACE DO TABULEIRO
% ------------------------------------------
imprimir_tabuleiro :-
    nl,
    imprimir_linha(1), write('---+---+---'), nl,
    imprimir_linha(2), write('---+---+---'), nl,
    imprimir_linha(3), nl.

imprimir_linha(L) :-
    write(' '), imprimir_celula(L, 1), write(' | '),
    imprimir_celula(L, 2), write(' | '),
    imprimir_celula(L, 3), nl.

% Se estiver ocupado, imprime a letra. Se não, imprime um hífen.
imprimir_celula(L, C) :- jogada(L, C, J), !, write(J).
imprimir_celula(_, _) :- write('-').