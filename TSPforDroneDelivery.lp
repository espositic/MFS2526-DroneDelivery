% =========================================================
% DRONE PER IL DELIVERY NELLA PROVINCIA DI TARANTO 
% =========================================================


% --- 1. DEFINIZIONE NODI E ARCHI ---
node(taranto).       
node(martina).       
node(grottaglie).    
node(manduria).      
node(castellaneta).  
node(pulsano).       

% Definizione raggiungibilità
reached(Y) :- cycle(taranto,Y).
reached(Y) :- cycle(X,Y), reached(X).

% Genera un arco per ogni nodo X e Y, dove X e Y sono due nodi diversi
edge(X,Y) :- node(X), node(Y), X != Y.


% --- 2. REGOLE DI GENERAZIONE DEL CICLO ---
% Obbligo di uscita
% Per ogni nodo, deve essere selezionato esattamente un arco uscente, 
{ cycle(X,Y) : edge(X,Y) } = 1 :- node(X).
% Obbligo di entrata
% Per ogni nodo, deve essere selezionato esattamente un arco entrante
{ cycle(X,Y) : edge(X,Y) } = 1 :- node(Y).


% --- 3. DATI GEOGRAFICI ---
% Alititudine dei nodi espressa in metri sul mare
altitude(taranto, 15).
altitude(martina, 431).
altitude(grottaglie, 130).
altitude(manduria, 79).
altitude(castellaneta, 245).
altitude(pulsano, 37).

% Distanza tra i nodi espressa in chilometri
dist_raw(taranto, martina, 30).
dist_raw(taranto, grottaglie, 20).
dist_raw(taranto, manduria, 35).
dist_raw(taranto, castellaneta, 33).
dist_raw(taranto, pulsano, 15).
dist_raw(martina, grottaglie, 14).
dist_raw(martina, manduria, 38).
dist_raw(martina, castellaneta, 32).
dist_raw(martina, pulsano, 40).
dist_raw(grottaglie, manduria, 22).
dist_raw(grottaglie, castellaneta, 45).
dist_raw(grottaglie, pulsano, 25).
dist_raw(manduria, pulsano, 20).
dist_raw(manduria, castellaneta, 60).
dist_raw(castellaneta, pulsano, 45).

% Codice per evitare di riportare due volte la stessa distanza per il percorso inverso
distance(X,Y,D) :- dist_raw(X,Y,D).
distance(X,Y,D) :- dist_raw(Y,X,D).


% --- 4. FUNZIONE DI COSTO ---
% Viene considerato il dislivello tra due nodi solo se positivo, altrimenti é trascurabile
elevation_diff(X,Y, Diff) :- altitude(X, H1), altitude(Y, H2), H2 > H1, Diff = H2 - H1.
elevation_diff(X,Y, 0)    :- altitude(X, H1), altitude(Y, H2), H2 <= H1.

% Costo Batteria = (Distanza * 2) + (Dislivello / 10)
battery_cost(X,Y,B) :- 
    distance(X,Y,D),
    elevation_diff(X,Y,Diff),
    BaseCost = D * 2,
    ClimbCost = Diff / 10,
    B = BaseCost + ClimbCost.

% Calcolo del costo totale (qui sommo distanza e batteria come indice di performance)
cost(X,Y,C) :- distance(X,Y,D), battery_cost(X,Y,B), C = D + B.

% Verifica completezza del ciclo
cycle_complete :- N = #count { X : node(X) }, 
                  N = #count { X : reached(X) }.
:- not cycle_complete.

% Calcolo della distanza totale
total_distance(TD) :- TD = #sum { D,X,Y : cycle(X,Y), distance(X,Y,D) }.

% Calcolo del consumo totale di batteria
total_battery(TB) :- TB = #sum { B,X,Y : cycle(X,Y), battery_cost(X,Y,B) }.


% --- 5. VISUALIZZAZIONE ---
#show cycle/2.
#show total_distance/1.
#show total_battery/1.


% --- 6. OTTIMIZZAZIONE ---
% Minimizza il consumo di batteria
#minimize { B,X,Y : cycle(X,Y), battery_cost(X,Y,B) }.