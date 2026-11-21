# Istruzioni di Deployment ed Esecuzione

## Prerequisiti
* **PostgreSQL** (versione 14 o superiore consigliata, per il supporto nativo al tipo `JSONB` e ai trigger PL/pgSQL).
* Client SQL grafico (**pgAdmin 4**) oppure interfaccia a riga di comando `psql`.

## Sequenza di esecuzione degli script
Creare un database vuoto ed eseguire gli script nel seguente ordine per rispettare i vincoli di integrità referenziale:

1. **`01_schema.sql`**
   Crea le 5 tabelle principali (`SoggettoNIS2`, `Responsabile`, `ServizioCritico`, `Asset`, `Fornitore`), le 4 tabelle associative (`Fornitura`, `Gestione`, `Supporto`, `Appalto`), la tabella centralizzata `StoricoModifiche`, i vincoli (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`), i 17 indici, i commenti metadati (`COMMENT ON`), la funzione trigger `gestisci_storico_e_versione()` e i 5 trigger `BEFORE UPDATE OR DELETE`.
2. **`02_popolamento.sql`**
   Popola il database con il dataset simulato (*Gruppo Ospedaliero Alpha S.p.A.* e *Banca di Credito Cooperativo Beta S.p.A.*) inserendo in sequenza le tabelle indipendenti, quelle dipendenti e infine le tabelle associative.
3. **`03_view_e_query.sql`**
   Crea la vista `v_profilo_acn`, esegue le interrogazioni analitiche e collauda il trigger di storicizzazione. Per rigenerare i 5 report presenti nella cartella `../csv/`, eseguire in **pgAdmin 4** ciascun blocco separatamente ed esportare il relativo risultato:
   * Vista `v_profilo_acn` $\rightarrow$ `profilo_acn.csv`
   * Query 2 (Catena di dipendenza critica) $\rightarrow$ `catena_dipendenze.csv`
   * Query 3 (Analisi del rischio *supply chain*) $\rightarrow$ `rischio_supply_chain.csv`
   * Query 4 (Matrice di governance CSIRT/ACN) $\rightarrow$ `governance.csv`
   * Blocco finale di test (`UPDATE` su `Gateway Pagamenti SEPA` e verifica su `StoricoModifiche`) $\rightarrow$ `test_storico_modifiche.csv`

> **Nota operativa:** eseguire il blocco finale di `UPDATE` una sola volta dopo `02_popolamento.sql` per evitare incrementi multipli del contatore `Versione` sul record di test. Per ripetere l'intera procedura da zero, ricreare il database vuoto prima di rilanciare `01_schema.sql`.
