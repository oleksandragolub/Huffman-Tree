%%%%%%%%%%%%%%%%%%%%%%%%%
% GOLUB OLEKSANDRA 856706
% ARESTA SIMONE 875192
%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTROLLI FATTI:
%%%%%%%%%%%%%%%%%%%%%%%%%

CL-USER 1 > (defparameter ht (he-generate-huffman-tree '((a 8) (b 3) (c 1) (d 1) (e 1) (f 1) (g 1) (h 1))))
HT

CL-USER 2 > ht
((A G H E F C D B) 17 (A 8) ((G H E F C D B) 9 ((G H E F) 4 ((G H) 2 (G 1) (H 1)) ((E F) 2 (E 1) (F 1))) ((C D B) 5 ((C D) 2 (C 1) (D 1)) (B 3))))

CL-USER 3 > (he-generate-symbol-bits-table ht)
((A (0)) (G (1 0 0 0)) (H (1 0 0 1)) (E (1 0 1 0)) (F (1 0 1 1)) (C (1 1 0 0)) (D (1 1 0 1)) (B (1 1 1)))

CL-USER 4 > (he-encode '(A B) ht)
(0 1 1 1)

CL-USER 5 > (he-decode '(0 1 1 1) ht)
(A B)

nota: text.txt contiene "AB D CD"
CL-USER 6 > (he-encode-file "test.txt" ht)
(0 1 1 1 1 1 0 1 1 1 0 0 1 1 0 1)

nota: text.txt contiene "A B D C D"
CL-USER 7 > (he-encode-file "test.txt" ht)
(0 1 1 1 1 1 0 1 1 1 0 0 1 1 0 1)

CL-USER 8 > (he-print-huffman-tree ht)
((A G H E F C D B) 17 (A 8) ((G H E F C D B) 9 ((G H E F) 4 ((G H) 2 (G 1) (H 1)) ((E F) 2 (E 1) (F 1))) ((C D B) 5 ((C D) 2 (C 1) (D 1)) (B 3))))
((A G H E F C D B) 17 (A 8) ((G H E F C D B) 9 ((G H E F) 4 ((G H) 2 (G 1) (H 1)) ((E F) 2 (E 1) (F 1))) ((C D B) 5 ((C D) 2 (C 1) (D 1)) (B 3))))

CL-USER 9 > (defparameter message '(A B))
MESSAGE

CL-USER 10 > message
(A B)

CL-USER 11 > (equal message (he-decode (he-encode message ht) ht))
T

%%%%%%%%%%%%%%%%%%%%%%%%%
% SPIEGAZIONE CODICE:
%%%%%%%%%%%%%%%%%%%%%%%%%

Funzioni "he-decode" e "choose-branch" sono identiche a quelle del testo della consegna.

Funzione "he-decode" ha dentro una funzione locale "decode-1" con bits (che rappresentano i bit (0/1) presi in input) e current-branch (che rappresenta il ramo corrente che si prende da huffman-tree).
Funzione "decode-1" stabilisce che, finche' non si esauriscono i bits del ramo corrente, non si analizza nessun altro ramo che verra' chiamato ricorsivamente.
Si crea la variabile locale "next-branch" con il primo bit da bits e il ramo corrente. 
Viene effettuato il controllo tramite funzione "leaf-p", che avvisa se oltre il prossimo nodo esistono altri nodi.
Nel caso in cui non esistono, chiama funzione "leaf-symbol" al prossimo nodo per trovare il simbolo.
Successivamente iniziamo ad analizzare i bits rimanenti, richiamando ricorsivamente "decode-1" su tutto il resto dell'albero.
Cosi si ritorna al ramo current-branch (non next-branch) che cerca di capire su quale altro ramo andare, avendo il resto di bits.

Funzione "choose-branch" analizza a secondo di quale cifra (0 oppure 1) andare in che altro nodo (che a sua volta potrebbe essere un ramo intermedio o finale).

Funzione "node-left" controlla se e' un nodo finale (atom) oppure no. 
Nel caso non lo e', si associa il contenuto di (caddr x) al nodo. 
da ricordare che: (caddr x) == (third x) == (car (cdr (cdr x))) 

Funzione "node-right" controlla se e' un nodo finale (atom) oppure no. 
Nel caso non lo e', si associa il contenuto di (cadddr x) al nodo. 
da ricordare che: (cadddr x) == (fourth x) == (car (cdr (cdr (cdr x))))

Funzione "leaf-p" controlla se non esistono altri nodi oltre quello prossimo.
Se non esistono, associa il peso al nodo (ovvero la frequenza assoluta associata a nodo). 
da ricordare che: usare (null (cdr (cdr x))) e' un modo efficace per testare se esistono altri nodi (oltre quello prossimo che si analizza) in avanti oppure no

Funzione "leaf-symbol" prende il primo simbolo del ramo e lo associa al nodo.



Funzione "he-encode" ha dentro una funzione locale "encode-1" con message (che rappresenta una lista di simboli presi in input) e current-branch (che rappresenta il ramo corrente che si prende da huffman-tree).
Funzione "encode-1" stabilisce che, finche' non si esauriscono tutti simboli del ramo corrente, non si analizza nessun altro ramo che verra' chiamato ricorsivamente.
Si crea la variabile locale "next-branch" con il primo simbolo di message e il ramo corrente.
Viene effettuato il controllo tramite funzione "leaf-p", che avvisa se oltre il prossimo nodo esistono altri nodi.
Nel caso in cui il prossimo nodo analizzato da choose-next-branch conicide con il risultato del node-left, si creano due chiamate ricorsive che analizzano il resto dei simboli (a seconda di quale cifra) partendo dalla radice dell'albero.
Successivamente si creano due chiamate ricorsive che stabiliscono se ci sono oppure no altri rami oltre al prossimo. Nel caso in cui non ci sono, si aggiungono al codice finale (bits) gli 1 e/o 0.
Dopo iniziamo ad analizzare i simboli di message rimanenti, richiamando ricorsivamente "encode-1" su tutto il resto dell'albero.
Cosi si ritorna al current-branch (non next-branch) che cerca di capire su quale altro ramo andare, avendo il resto di simboli di message.

Funzione "choose-next-branch" stabilisce in quale prossimo nodo si va.

Funzione "control" fa seguenti controlli:
1) se non esiste il prossimo ramo, ritorna nil;
2) se esiste ed e' un atomo (non ci sono altri rami), ritorna il ramo a cui e' associato il simbolo; 
3) se esiste e non e' un atomo (ci sono altri rami), analizza ricorsivamente il resto dei rami finche' non arriva nel secondo caso;



Funzione "he-encode-file" applica sul contenuto del file .txt ben formattato la funzione "he-encode".

Funzione "flatten" appiattisce la lista di liste.

Funzione "read-file-as-lines" apre il file e inserisce il contenuto del file nel formato delle stringhe.

Funzione "line-as-list" prende le stringhe lette e li trasforma nelle liste.

Funzione "explode" viene applicata ad un atomo:
CL-USER 12 : 3 > (explode 'a)
(#\A)

Funzione "control-input-start" usa la funzione "explode" e la applica su tutta la lista:
CL-USER 13 > (control-input-start '(ab c))
((#\A #\B) (#\C))
CL-USER 14 > (control-input-start '(a b c))
((#\A) (#\B) (#\C))

Funzione "control-input-end" converte la lista di simboli ((#\A #\B) (#\C)) in una lista di simboli (A B C):
CL-USER 15 > (control-input-end (flatten '((#\A #\B) (#\C))))
(A B C)
CL-USER 16 > (control-input-end (flatten '((#\A) (#\B) (#\C))))
(A B C)

Funzione "control-input" unisce le funzioni "control-input-start" e "control-input-start".
esempio:
CL-USER 17 > (control-input '(ab c))
(A B C)



Funzione "he-generate-huffman-tree" controlla per prima cosa se ci sono meno di due simboli nella coppia simbolo-peso. In caso negativo si genera un errore. 
Richiama funzione esterna "generate-tree", che prende in input la coppia simbolo-peso corretta. 

Funzione "generate-tree" controlla se l'albero e' gia' stato creato oppure no. 
da ricordare che: usare (null (cdr x)) e' un modo efficace per testare se esistono altri symbols-n-weights (oltre quello prossimo che si analizza) in avanti oppure no.
Nel caso in cui non e' stato ancora creato, si prende una prima coppia da symbols-n-weights. 
Successivamente si crea una variabile locale "lista" sulla chiale viene richiamata la funzione "stable-sort" che gestisce una lista di liste (symbols-n-weights), aiutandosi con la funzione "funz" che confronta le liste tra di loro. 
Cosi si genera un albero di huffman, appendendo e concatenando le liste di coppie appiattite tramite funzione "flatten-tree". 

Funzione "funz" stabilisce se una coppia simbolo-peso e' maggiore dell'altra coppia. 

Funzione "flatten-tree" appiattisce la lista di liste, creando cosi un'unica lista;



Funzione "he-generate-symbol-bits-table" ha dentro una funzione locale "generate-symbol-bits-table-1" con huffman-tree che genera una lista nuova 
Successivamente viene controllato se la lista non e' nulla. In questo caso si concatena una serie di coppe simbolo-bit, altrimenti ritorna nil. 
da notare: il bit si trova tramite (he-encode (list (car list)) huffman-tree);
Dopo si fa la stessa cosa tramite una chiamata ricorsiva con il resto dell'albero;



Funzione "he-print-huffman-tree" stampa intero albero di huffman.




















