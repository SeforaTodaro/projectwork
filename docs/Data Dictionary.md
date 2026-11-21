# Data Dictionary

Questo documento descrive la struttura logica e fisica delle 10 tabelle che compongono la base di dati PostgreSQL a supporto degli adempimenti previsti dalla Direttiva (UE) 2022/2555 (NIS2) e dal d.lgs. 138/2024, suddivise in:
* 5 Tabelle Principali: SoggettoNIS2, Responsabile, ServizioCritico, Asset, Fornitore
* 4 Tabelle Associative (3NF): Fornitura, Gestione, Supporto, Appalto
* 1 Tabella di Audit e Storicizzazione: StoricoModifiche

---

## 1. Tabelle Principali

### 1.1 SoggettoNIS2
Censisce le organizzazioni pubbliche e private rientranti nel perimetro applicativo della Normativa NIS2.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDSoggettoNIS2 | SERIAL | PRIMARY KEY | Identificativo interno univoco auto-incrementale del soggetto regolamentato |
| RagioneSociale | VARCHAR(150) | NOT NULL | Denominazione legale completa dell'organizzazione |
| CodiceIdentificativo | VARCHAR(50) | UNIQUE NOT NULL | Partita IVA (per soggetti privati) o Codice IPA / Codice Fiscale (per enti pubblici) |
| CodiceATECO | VARCHAR(10) | — | Codice di classificazione dell'attività economica (ATECO / NACE) |
| DomicilioDigitale | VARCHAR(100) | — | Indirizzo PEC ufficiale utilizzato per le comunicazioni regolamentari con ACN |
| SettoreCriticita | VARCHAR(50) | NOT NULL, CHECK | Classificazione settoriale NIS2 ("Settore Altamente Critico", "Settore Critico", "Altra Tipologia di Soggetto") |
| TipologiaNIS2 | VARCHAR(20) | NOT NULL, CHECK | Categoria normativa assegnata all'ente ("Essenziale", "Importante") |
| UbicazioneSedeStatoUE | VARCHAR(50) | NOT NULL | Stato membro dell'Unione Europea in cui è stabilita la sede principale |
| UbicazioneSedeCitta | VARCHAR(50) | NOT NULL | Comune in cui è ubicata la sede principale |
| UbicazioneSedeVia | VARCHAR(100) | NOT NULL | Denominazione della via o piazza (o altro) della sede principale |
| UbicazioneSedeNumeroCivico | VARCHAR(10) | — | Numero civico della sede principale |
| UbicazioneSedeCAP | VARCHAR(10) | NOT NULL | Codice di Avviamento Postale della sede principale |
| Versione | INT | NOT NULL DEFAULT 1, CHECK (Versione >= 1) | Contatore progressivo della versione corrente del record |
| DataUltimoAggiornamento | TIMESTAMP | NOT NULL DEFAULT CURRENT_TIMESTAMP, CHECK (<= CURRENT_TIMESTAMP) | Data e ora di creazione o dell'ultima modifica apportata al record |

---

### 1.2 Responsabile
Registra le figure interne all'organizzazione.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDResponsabile | SERIAL | PRIMARY KEY | Identificativo interno univoco auto-incrementale del responsabile |
| CodiceFiscale | VARCHAR(30) | UNIQUE NOT NULL | Codice fiscale univoco della persona fisica |
| Nome | VARCHAR(50) | NOT NULL | Nome anagrafico del responsabile |
| Cognome | VARCHAR(50) | NOT NULL | Cognome anagrafico del responsabile |
| ContattoEmail | VARCHAR(100) | NOT NULL | Indirizzo email istituzionale per le comunicazioni operative |
| ContattoTelefonico | VARCHAR(20) | — | Recapito telefonico diretto per la reperibilità in caso di incidente |
| RuoloAziendale | VARCHAR(100) | NOT NULL | Funzione ricoperta nell'organigramma interno (es. CISO, Direttore Generale) |
| TitoloGiuridico | VARCHAR(100) | NOT NULL | Qualifica formale ai fini NIS2 (es. Punto di contatto ACN, Referente CSIRT) |
| SedeDiRiferimento | VARCHAR(200) | — | Indirizzo completo della sede operativa presso cui opera il referente |
| Versione | INT | NOT NULL DEFAULT 1, CHECK (Versione >= 1) | Contatore progressivo della versione corrente del record |
| DataUltimoAggiornamento | TIMESTAMP | NOT NULL DEFAULT CURRENT_TIMESTAMP, CHECK (<= CURRENT_TIMESTAMP) | Data e ora di creazione o dell'ultima modifica apportata al record |
| IDSoggettoNIS2 | INT | NOT NULL, FOREIGN KEY -> SoggettoNIS2(IDSoggettoNIS2) (ON DELETE RESTRICT) | Chiave esterna verso l'organizzazione regolamentata di appartenenza |

---

### 1.3 ServizioCritico
Descrive i servizi essenziali o critici erogati dal soggetto NIS2 sul territorio dell'Unione Europea.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDServizioCritico | SERIAL | PRIMARY KEY | Identificativo interno univoco auto-incrementale del servizio critico |
| Nome | VARCHAR(100) | NOT NULL | Denominazione identificativa del servizio erogato |
| Descrizione | TEXT | — | Descrizione estesa delle funzioni e dell'operatività del servizio |
| MacroArea | VARCHAR(100) | NOT NULL | Comparto o ambito operativo disciplinato dagli allegati NIS2 |
| CategoriaDiRilevanza | VARCHAR(20) | NOT NULL, CHECK | Priorità di continuità e ripristino del servizio ("Critico", "Alto", "Medio", "Basso") |
| Versione | INT | NOT NULL DEFAULT 1, CHECK (Versione >= 1) | Contatore progressivo della versione corrente del record |
| DataUltimoAggiornamento | TIMESTAMP | NOT NULL DEFAULT CURRENT_TIMESTAMP, CHECK (<= CURRENT_TIMESTAMP) | Data e ora di creazione o dell'ultima modifica apportata al record |
| IDSoggettoNIS2 | INT | NOT NULL, FOREIGN KEY -> SoggettoNIS2(IDSoggettoNIS2) (ON DELETE RESTRICT) | Chiave esterna verso il soggetto regolamentato che eroga il servizio |

---

### 1.4 Asset
Censisce le risorse tecnologiche, applicative, infrastrutturali e di rete gestite dall'organizzazione.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDAsset | SERIAL | PRIMARY KEY | Identificativo interno univoco auto-incrementale dell'asset |
| Nome | VARCHAR(100) | NOT NULL | Nome identificativo del sistema, applicativo o apparato |
| Tipologia | VARCHAR(50) | NOT NULL | Categoria tecnica della risorsa (es. Server Virtuale, Apparato di Rete, Database) |
| StatoOperativo | VARCHAR(100) | NOT NULL | Stato corrente nel ciclo di vita (es. In produzione, In manutenzione, Dismesso) |
| SpazioDiIndirizzamento | VARCHAR(100) | — | Indirizzo IP, subnet logica o indicazione "Non in rete" |
| CriticitaOperativa | VARCHAR(20) | NOT NULL, CHECK | Livello di impatto operativo in caso di indisponibilità ("Critico", "Alto", "Medio", "Basso") |
| Versione | INT | NOT NULL DEFAULT 1, CHECK (Versione >= 1) | Contatore progressivo della versione corrente del record |
| DataUltimoAggiornamento | TIMESTAMP | NOT NULL DEFAULT CURRENT_TIMESTAMP, CHECK (<= CURRENT_TIMESTAMP) | Data e ora di creazione o dell'ultima modifica apportata al record |
| IDSoggettoNIS2 | INT | NOT NULL, FOREIGN KEY -> SoggettoNIS2(IDSoggettoNIS2) (ON DELETE RESTRICT) | Chiave esterna verso il soggetto regolamentato titolare dell'asset |

---

### 1.5 Fornitore
Censisce i fornitori terzi e i prestatori di servizi ICT appartenenti alla catena di approvvigionamento (Supply Chain).

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDFornitore | SERIAL | PRIMARY KEY | Identificativo interno univoco auto-incrementale del fornitore |
| RagioneSociale | VARCHAR(150) | NOT NULL | Denominazione legale completa della terza parte |
| CodiceIdentificativo | VARCHAR(50) | UNIQUE NOT NULL | Partita IVA o Codice IPA univoco del fornitore |
| ContattoReferente | VARCHAR(100) | NOT NULL | Recapito diretto (email, PEC o telefono) del referente contrattuale/tecnico |
| SedeLegale | VARCHAR(200) | NOT NULL | Indirizzo completo della sede legale del fornitore |
| TipologiaFornitura | VARCHAR(100) | NOT NULL | Oggetto della fornitura (es. Servizi SOC/MDR, Manutenzione Hardware, Cloud Backup) |
| TipologiaAccesso | VARCHAR(100) | NOT NULL | Modalità di accesso ai sistemi del cliente (es. Remoto, Presidio fisico, Nessun accesso diretto) |
| LivelloDiCriticita | VARCHAR(20) | NOT NULL, CHECK | Indice di rischiosità associato al fornitore ("Critico", "Alto", "Medio", "Basso") |
| Versione | INT | NOT NULL DEFAULT 1, CHECK (Versione >= 1) | Contatore progressivo della versione corrente del record |
| DataUltimoAggiornamento | TIMESTAMP | NOT NULL DEFAULT CURRENT_TIMESTAMP, CHECK (<= CURRENT_TIMESTAMP) | Data e ora di creazione o dell'ultima modifica apportata al record |

---

## 2. Tabelle Associative (Risoluzione Relazioni N:M)

### 2.1 Fornitura
Risolve l'associazione molti-a-molti tra SoggettoNIS2 e Fornitore.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDFornitura | SERIAL | PRIMARY KEY | Identificativo univoco del rapporto di fornitura |
| IDSoggettoNIS2 | INT | NOT NULL, FOREIGN KEY -> SoggettoNIS2(IDSoggettoNIS2) (ON DELETE CASCADE), UNIQUE (IDSoggettoNIS2, IDFornitore) | Riferimento al soggetto NIS2 committente |
| IDFornitore | INT | NOT NULL, FOREIGN KEY -> Fornitore(IDFornitore) (ON DELETE CASCADE), UNIQUE (IDSoggettoNIS2, IDFornitore) | Riferimento al fornitore terzo contrattualizzato |

---

### 2.2 Gestione
Risolve l'associazione molti-a-molti tra Responsabile e ServizioCritico.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDGestione | SERIAL | PRIMARY KEY | Identificativo univoco dell'assegnazione di governance |
| IDResponsabile | INT | NOT NULL, FOREIGN KEY -> Responsabile(IDResponsabile) (ON DELETE CASCADE), UNIQUE (IDResponsabile, IDServizioCritico) | Riferimento al referente interno responsabile |
| IDServizioCritico | INT | NOT NULL, FOREIGN KEY -> ServizioCritico(IDServizioCritico) (ON DELETE CASCADE), UNIQUE (IDResponsabile, IDServizioCritico) | Riferimento al servizio critico supervisionato |

---

### 2.3 Supporto
Risolve l'associazione molti-a-molti tra ServizioCritico e Asset.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDSupporto | SERIAL | PRIMARY KEY | Identificativo univoco della dipendenza infrastrutturale |
| IDServizioCritico | INT | NOT NULL, FOREIGN KEY -> ServizioCritico(IDServizioCritico) (ON DELETE CASCADE), UNIQUE (IDServizioCritico, IDAsset) | Riferimento al servizio critico erogato |
| IDAsset | INT | NOT NULL, FOREIGN KEY -> Asset(IDAsset) (ON DELETE CASCADE), UNIQUE (IDServizioCritico, IDAsset) | Riferimento all'asset tecnologico a supporto del servizio |

---

### 2.4 Appalto
Risolve l'associazione molti-a-molti tra Fornitore e Asset.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDAppalto | SERIAL | PRIMARY KEY | Identificativo univoco dell'affidamento operativo sull'asset |
| IDFornitore | INT | NOT NULL, FOREIGN KEY -> Fornitore(IDFornitore) (ON DELETE CASCADE), UNIQUE (IDFornitore, IDAsset) | Riferimento al fornitore incaricato della gestione/manutenzione |
| IDAsset | INT | NOT NULL, FOREIGN KEY -> Asset(IDAsset) (ON DELETE CASCADE), UNIQUE (IDFornitore, IDAsset) | Riferimento all'asset affidato alla terza parte |

---

## 3. Tabella di Audit e Storicizzazione

### 3.1 StoricoModifiche
Registro centralizzato alimentato automaticamente dalla funzione trigger gestisci_storico_e_versione() su eventi BEFORE UPDATE OR DELETE delle cinque tabelle principali.

| Campo | Tipo SQL | Vincoli | Descrizione |
| :--- | :--- | :--- | :--- |
| IDStorico | SERIAL | PRIMARY KEY | Identificativo progressivo dell'evento di audit registrato |
| TabellaOrigine | VARCHAR(50) | NOT NULL | Nome della tabella principale sorgente dell'evento (TG_TABLE_NAME) |
| IDRecord | INT | NOT NULL | Valore della chiave primaria del record modificato o eliminato |
| Operazione | VARCHAR(10) | NOT NULL, CHECK (Operazione IN ('UPDATE', 'DELETE')) | Tipologia di operazione DML intercettata dal trigger |
| VersioneStorica | INT | NOT NULL | Numero di versione posseduto dal record prima della modifica o cancellazione |
| DatiPrecedenti | JSONB | NOT NULL | Rappresentazione binaria completa della tupla precedente (to_jsonb(OLD)) |
| DataModifica | TIMESTAMP | NOT NULL DEFAULT CURRENT_TIMESTAMP | Data e ora esatta in cui è stata eseguita l'operazione |
