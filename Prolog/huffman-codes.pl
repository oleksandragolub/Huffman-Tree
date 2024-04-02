
% per generare l'albero dobbiamo affrontare 3 problemi principalmente:
% 1)verificare che nell'albero non siano presenti simboli duplicati
% 2)creare i nodi
% 3)garantire che i nodi siano ordinati in ordine decrescente a seconda
% della frequenza
%--------------------------------------------------------------------------------
is_symbol(X) :-
    not(number(X)),  %controlla se X non и un numero
    !.

he_generate_huffman_tree([],[]) :- !.
he_generate_huffman_tree([[Sym, Freq]], HuffmanTree) :-
    is_symbol(Sym),
    number(Freq),
    create_leaf([Sym, Freq], Leaf),
    create_tree(Leaf, HuffmanTree),
    !.
he_generate_huffman_tree([[Sym, Freq], [Sym2, Freq2]| Rest], HuffmanTree) :-
    duplicates([[Sym, Freq], [Sym2, Freq2]| Rest]),
    create_leaf([[Sym, Freq], [Sym2, Freq2]| Rest], Leafs),
    create_tree(Leafs, HuffmanTree),
    !.
%--------------------------------------------------------------------------------
% per controllare che non siano presenti simboli duplicati, sfrutto una
% proprietа del predicato di ordinamento di prolog, quest'ultima oltre a
% ordinare la lista, elimina appunto elementi duplicati. A questo punto
% mi basterа confrontare la lunghezza della lista prima dell'ordinamento
% e quella dopo, se hanno lunghezza diversa, allora sono presenti
% simboli duplicati all'interno della lista.

duplicates([[_Sym, _Freq]]) :- !.
duplicates([[Sym, Freq], [Sym2,Freq2] | Rest]) :-
    sort(1, @< , [[Sym, Freq], [Sym2,Freq2] | Rest], L1),
    length( [[Sym, Freq], [Sym2,Freq2] | Rest], Lun1),
    length( L1, Lun2),
    Lun1 = Lun2,
    !.


%predicato che inizializza le foglie dell'albero
create_leaf([], []) :- !.
create_leaf([[Sym, Freq]|Rest], [node(Sym, Freq, nil, nil)| Others]) :-
    create_leaf(Rest, Others).

%predicato che ordina i nodi in base alla frequenza
node_sort([node(_Sym, _Freq, _L, _R)], [node(_Sym, _Freq, _L, _R)]) :- !.
node_sort([node(Sym ,Freq , L, R)| Rest], Sorted) :-
    sort(2, @=<, [node(Sym, Freq, L, R) | Rest], Sorted),
    !.
%predicato ausiliare per la creazione dell'albero
create_tree([node(_Sym, _Freq, _L, _R)], node(_Sym, _Freq, _L, _R)) :- !.
create_tree(Leafs, Tree) :-
	node_sort(Leafs, [node(Sym, Freq ,L, R),
                          node(Sym2, Freq2, L2, R2)| Rest]),
	Frequences is Freq + Freq2,
	string_concat(Sym, Sym2, Label),
	create_tree([node(Label, Frequences,node(Sym , Freq, L, R),
                          node(Sym2, Freq2, L2, R2))| Rest], Tree),
        !.


%encode
%--------------------------------------------------------------------------------
he_encode([H], HuffmanTree, Bits) :-
    sym_code(H, HuffmanTree, Bits), !.
he_encode([H | T], HuffmanTree, Bits) :-
    sym_code(H,  HuffmanTree, Bits2),
    he_encode(T,  HuffmanTree, Bits3),
    append(Bits2, Bits3, Bits), !.

sym_code(H, node(Sym, _, nil, nil),[]) :-
    atom_chars(Sym, SymList),
    memberchk(H, SymList),
    !.

sym_code(H, node(Sym, _, node(LSym, LFreq, LT, RT), _), Bits) :-
    atom_chars(Sym, SymList),
    memberchk(H, SymList),
    sym_code(H, node(LSym, LFreq, LT, RT), Bits2),
    append([0], Bits2, Bits),
    !.

sym_code(H, node(Sym, _, _, node(RSym, RFreq, LT, RT)), Bits) :-
    atom_chars(Sym, SymList),
    memberchk(H, SymList),
    sym_code(H, node(RSym, RFreq, LT, RT), Bits2),
    append([1], Bits2, Bits),
    !.
%--------------------------------------------------------------------------------
he_encode_file(Filename, HuffmanTree, Encoded) :-
    leggi(Filename, Ris),
    converti(Ris, Ris2),
    no_space(Ris2, Ris3),
    he_encode(Ris3, HuffmanTree, Encoded),
    !.

leggi(Filename, Ris) :-
    open(Filename , read, Str),
    read_file(Str,Ris),
    close(Str),
    !.

converti([], []) :- !.
converti([X], Ris) :-
    atom_chars(X, Ris),
    !.
converti([X | Xs], Ris) :-
    atom_chars(X, L1),
    append(L1, L2, Ris),
    converti(Xs, L2),
    !.

no_space([], []) :- !.
no_space([X], []) :-   %rimuove gli spazi da una lista
    X = ' ',
    !.
no_space([X], [X]) :-
    X \= ' ',
    !.
no_space([X| Xs], [X | Zs]) :-
    X \= ' ',
    no_space(Xs, Zs),
    !.

no_space([X| Xs], Zs) :-
    X = ' ',
    no_space(Xs, Zs),
    !.

read_file(Stream,[]) :-
    at_end_of_stream(Stream).

read_file(Stream,[X|L]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_string(Stream,X),
    read_file(Stream,L), !.

% decode
% --------------------------------------------------------------------------------
%
he_decode([], _, []) :- !.
he_decode([H], HuffmanTree, Message) :-
    sym_decode([H], HuffmanTree, Message),
    !.
he_decode([H | T], HuffmanTree, Message) :-
    sym_decode([H | T], HuffmanTree, Symbol),
    he_encode(Symbol, HuffmanTree, SymEncoded),
    length(SymEncoded, LSEncoded),
    trim([H | T], LSEncoded, NewList),
    he_decode(NewList , HuffmanTree, Message3),
    append(Symbol, Message3, Message),
    !.


sym_decode(_, node(Sym, _, nil, nil), [Sym]) :- !.

sym_decode([Bit | Rest], node(_, _, L, _), [Sym]) :-
    Bit = 0,
    sym_decode(Rest, L, [Sym]),
    !.
sym_decode([Bit | Rest], node(_, _, _, R), [Sym]) :-
    Bit = 1,
    sym_decode(Rest, R, [Sym]),
    !.


trim(L,N,S) :-
  length(P,N) ,
  append(P,S,L).  %toglie i primi N elementi da L


he_generate_symbol_bits_table(node(Sym, _, L, R), BitsTable) :-
    atom_chars(Sym, SymList),
    generate_bits_table(SymList, node(Sym, _, L, R), Table),
    sort(Table, BitsTable),
    !.

generate_bits_table([H], HuffmanTree, [H, Code]) :-
    sym_code(H, HuffmanTree, Code),
    !.
generate_bits_table([H | T], HuffmanTree, [[H, Code] | Rest]) :-
    sym_code(H, HuffmanTree, Code),
    generate_bits_table(T, HuffmanTree, Rest),
    !.


he_print_huffman_tree(node(Sym, Freq, nil, nil)) :-
    write(Sym-Freq),
    !.
he_print_huffman_tree(node(Sym, Freq, L, R)) :-
    write(Sym-Freq),
    he_print_huffman_tree(L),
    he_print_huffman_tree(R),
    !.
he_print_huffman_tree(node(Sym, Freq, L, _)) :-
    write(Sym-Freq),
    write(" L "),
    he_print_huffman_tree(L),
    !.

he_print_huffman_tree(node(Sym, Freq, _, R)) :-
    write(Sym-Freq),
    write(" R "),
    he_print_huffman_tree(R),
    !.











