
-he_generate_huffman_tree/2-> prende in input una lista di coppie 
[simbolo peso], nella forma :
[[a,3],[b,2]...].
Secondo argomento unifica con la radice dell'albero di Huffman generato.

-duplicates/1 -> controlla che nella lista non siano presenti simboli
duplicati, e.g. [[a,5], [b,2], [a,1], [c,2]]

-create_leaf/2 -> prende in input la lista di coppie simbolo-peso
e genera una lista di nodi foglia dell'albero.

-node_sort/2 -> prende in input la lista di nodi non ordinata e il secondo 
argomento unifica con la lista ordinata in ordine decrescente per frequenza.

-create_tree/2 -> predicato ausiliaro principale per la creazione
dell'albero, prende in input la lista di nodi e il secondo argomento
unifica con la radice dell'albero


-he_encode/3 -> prende una lista dei simboli e l'huffman tree, il terzo
argomento viene unificato con la codifica dei simboli

-sym_code/3 -> predicato ausiliare per la codifica, 
prende un simbolo, l'albero di huffman e il terzo argomento viene unificato 
con la codifica 

-he_encode_file/3 -> prende il file name, l'albero di huffman e il terzo
argomento unifica con la codifica del contenuto del file.
Come predicati ausiliari utilizza:
	-leggi/2 -> predicato che si occupa di leggere il contenuto del file
	-converti/2 -> converte una lista del tipo [ciao, come, stai]
	in una del tipo [c,i,a,o,c,o,m...,a,i], ci serve perchè il predicato
	'leggi' ci ritornerà una lista del primo tipo
	-no_space/2 -> il secondo argomento viene unificato con una lista
	che non contiene ' ' come elemento 
	e.g. no_space([a,c, ' ', b], X)
	X= [a,b,c].
	-read_file/2 -> predicato ausiliare per leggi/2


-he_decode/3 -> prende come argomento una lista di bits, l'ht e 
il terzo argomento unifica con la lista di bit decodificata

-sym_decode/3 -> predicato ausiliario per he_decode/3

-trim/3 -> toglie i primi N elementi da L, questo predicato risulterà utile
per la decode, siccome rimuoveremo dalla lista di bit da codificare 
man mano i bit già codificati.

-he_generate_symbol_bits_table/2 -> crea una lista di coppie 
simbolo-codifica, prende come primo argomento l'ht e il secondo
viene unificato con la lista di coppie.

->he_print_huffman_tree/1 -> stampa la radice dell'albero di huffman
