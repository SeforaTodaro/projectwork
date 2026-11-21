-- CREAZIONE TABELLE PRINCIPALI
CREATE TABLE SoggettoNIS2 (
    IDSoggettoNIS2 SERIAL PRIMARY KEY,
    RagioneSociale VARCHAR(150) NOT NULL,
    CodiceIdentificativo VARCHAR(50) UNIQUE NOT NULL,
    CodiceATECO VARCHAR(10),
    DomicilioDigitale VARCHAR(100),
    SettoreCriticita VARCHAR(50) NOT NULL
        CHECK (SettoreCriticita IN ('Settore Altamente Critico', 'Settore Critico', 'Altra Tipologia di Soggetto')),
    TipologiaNIS2 VARCHAR(20) NOT NULL
        CHECK (TipologiaNIS2 IN ('Essenziale', 'Importante')),
    UbicazioneSedeStatoUE VARCHAR(50) NOT NULL,
    UbicazioneSedeCitta VARCHAR(50) NOT NULL,
    UbicazioneSedeVia VARCHAR(100) NOT NULL,
    UbicazioneSedeNumeroCivico VARCHAR(10),
    UbicazioneSedeCAP VARCHAR(10) NOT NULL,
    Versione INT NOT NULL DEFAULT 1 CHECK (Versione >= 1),
    DataUltimoAggiornamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        CHECK (DataUltimoAggiornamento <= CURRENT_TIMESTAMP)
);

CREATE TABLE Responsabile (
    IDResponsabile SERIAL PRIMARY KEY,
    CodiceFiscale VARCHAR(30) UNIQUE NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    ContattoEmail VARCHAR(100) NOT NULL,
    ContattoTelefonico VARCHAR(20),
    RuoloAziendale VARCHAR(100) NOT NULL,
    TitoloGiuridico VARCHAR(100) NOT NULL,
    SedeDiRiferimento VARCHAR(200),
    Versione INT NOT NULL DEFAULT 1 CHECK (Versione >= 1),
    DataUltimoAggiornamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        CHECK (DataUltimoAggiornamento <= CURRENT_TIMESTAMP),
    IDSoggettoNIS2 INT NOT NULL,
    CONSTRAINT fk_responsabile_soggetto FOREIGN KEY (IDSoggettoNIS2)
        REFERENCES SoggettoNIS2(IDSoggettoNIS2) ON DELETE RESTRICT
);

CREATE TABLE ServizioCritico (
    IDServizioCritico SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Descrizione TEXT,
    MacroArea VARCHAR(100) NOT NULL,
    CategoriaDiRilevanza VARCHAR(20) NOT NULL
        CHECK (CategoriaDiRilevanza IN ('Critico', 'Alto', 'Medio', 'Basso')),
    Versione INT NOT NULL DEFAULT 1 CHECK (Versione >= 1),
    DataUltimoAggiornamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        CHECK (DataUltimoAggiornamento <= CURRENT_TIMESTAMP),
    IDSoggettoNIS2 INT NOT NULL,
    CONSTRAINT fk_servizio_soggetto FOREIGN KEY (IDSoggettoNIS2)
        REFERENCES SoggettoNIS2(IDSoggettoNIS2) ON DELETE RESTRICT
);

CREATE TABLE Asset (
    IDAsset SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Tipologia VARCHAR(50) NOT NULL,
    StatoOperativo VARCHAR(100) NOT NULL,
    SpazioDiIndirizzamento VARCHAR(100),
    CriticitaOperativa VARCHAR(20) NOT NULL
        CHECK (CriticitaOperativa IN ('Critico', 'Alto', 'Medio', 'Basso')),
    Versione INT NOT NULL DEFAULT 1 CHECK (Versione >= 1),
    DataUltimoAggiornamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        CHECK (DataUltimoAggiornamento <= CURRENT_TIMESTAMP),
    IDSoggettoNIS2 INT NOT NULL,
    CONSTRAINT fk_asset_soggetto FOREIGN KEY (IDSoggettoNIS2)
        REFERENCES SoggettoNIS2(IDSoggettoNIS2) ON DELETE RESTRICT
);

CREATE TABLE Fornitore (
    IDFornitore SERIAL PRIMARY KEY,
    RagioneSociale VARCHAR(150) NOT NULL,
    CodiceIdentificativo VARCHAR(50) UNIQUE NOT NULL,
    ContattoReferente VARCHAR(100) NOT NULL,
    SedeLegale VARCHAR(200) NOT NULL,
    TipologiaFornitura VARCHAR(100) NOT NULL,
    TipologiaAccesso VARCHAR(100) NOT NULL,
    LivelloDiCriticita VARCHAR(20) NOT NULL
        CHECK (LivelloDiCriticita IN ('Critico', 'Alto', 'Medio', 'Basso')),
    Versione INT NOT NULL DEFAULT 1 CHECK (Versione >= 1),
    DataUltimoAggiornamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        CHECK (DataUltimoAggiornamento <= CURRENT_TIMESTAMP)
);

-- CREAZIONE TABELLE ASSOCIATIVE (NORMALIZZAZIONE 3NF PER RELAZIONI N:M)
CREATE TABLE Fornitura (
    IDFornitura SERIAL PRIMARY KEY,
    IDSoggettoNIS2 INT NOT NULL,
    IDFornitore INT NOT NULL,
    CONSTRAINT fk_fornitura_soggetto FOREIGN KEY (IDSoggettoNIS2)
        REFERENCES SoggettoNIS2(IDSoggettoNIS2) ON DELETE CASCADE,
    CONSTRAINT fk_fornitura_fornitore FOREIGN KEY (IDFornitore)
        REFERENCES Fornitore(IDFornitore) ON DELETE CASCADE,
    CONSTRAINT uc_soggetto_fornitore UNIQUE (IDSoggettoNIS2, IDFornitore)
);

CREATE TABLE Gestione (
    IDGestione SERIAL PRIMARY KEY,
    IDResponsabile INT NOT NULL,
    IDServizioCritico INT NOT NULL,
    CONSTRAINT fk_gestione_responsabile FOREIGN KEY (IDResponsabile)
        REFERENCES Responsabile(IDResponsabile) ON DELETE CASCADE,
    CONSTRAINT fk_gestione_servizio FOREIGN KEY (IDServizioCritico)
        REFERENCES ServizioCritico(IDServizioCritico) ON DELETE CASCADE,
    CONSTRAINT uc_responsabile_servizio UNIQUE (IDResponsabile, IDServizioCritico)
);

CREATE TABLE Supporto (
    IDSupporto SERIAL PRIMARY KEY,
    IDServizioCritico INT NOT NULL,
    IDAsset INT NOT NULL,
    CONSTRAINT fk_supporto_servizio FOREIGN KEY (IDServizioCritico)
        REFERENCES ServizioCritico(IDServizioCritico) ON DELETE CASCADE,
    CONSTRAINT fk_supporto_asset FOREIGN KEY (IDAsset)
        REFERENCES Asset(IDAsset) ON DELETE CASCADE,
    CONSTRAINT uc_servizio_asset UNIQUE (IDServizioCritico, IDAsset)
);

CREATE TABLE Appalto (
    IDAppalto SERIAL PRIMARY KEY,
    IDFornitore INT NOT NULL,
    IDAsset INT NOT NULL,
    CONSTRAINT fk_appalto_fornitore FOREIGN KEY (IDFornitore)
        REFERENCES Fornitore(IDFornitore) ON DELETE CASCADE,
    CONSTRAINT fk_appalto_asset FOREIGN KEY (IDAsset)
        REFERENCES Asset(IDAsset) ON DELETE CASCADE,
    CONSTRAINT uc_fornitore_asset UNIQUE (IDFornitore, IDAsset)
);

-- TABELLA CENTRALIZZATA PER LO STORICO DELLE VERSIONI
CREATE TABLE StoricoModifiche (
    IDStorico SERIAL PRIMARY KEY,
    TabellaOrigine VARCHAR(50) NOT NULL,
    IDRecord INT NOT NULL,
    Operazione VARCHAR(10) NOT NULL CHECK (Operazione IN ('UPDATE', 'DELETE')),
    VersioneStorica INT NOT NULL,
    DatiPrecedenti JSONB NOT NULL,
    DataModifica TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- INDICI PER INTEGRITÀ REFERENZIALE E PERFORMANCE DELLE QUERY
-- Indici di ricerca e filtro per classificazione normativa, criticità e storico
CREATE INDEX idx_soggettonis2_tipologia ON SoggettoNIS2(TipologiaNIS2);
CREATE INDEX idx_soggettonis2_settore ON SoggettoNIS2(SettoreCriticita);
CREATE INDEX idx_servizio_rilevanza ON ServizioCritico(CategoriaDiRilevanza);
CREATE INDEX idx_asset_criticita ON Asset(CriticitaOperativa);
CREATE INDEX idx_fornitore_criticita ON Fornitore(LivelloDiCriticita);
CREATE INDEX idx_storico_tabella_record ON StoricoModifiche(TabellaOrigine, IDRecord);

-- Indici sulle chiavi esterne delle tabelle dipendenti
CREATE INDEX idx_responsabile_soggetto ON Responsabile(IDSoggettoNIS2);
CREATE INDEX idx_servizio_soggetto ON ServizioCritico(IDSoggettoNIS2);
CREATE INDEX idx_asset_soggetto ON Asset(IDSoggettoNIS2);

-- Indici sulle tabelle associative (navigazione bidirezionale relazioni N:M)
CREATE INDEX idx_fornitura_soggetto ON Fornitura(IDSoggettoNIS2);
CREATE INDEX idx_fornitura_fornitore ON Fornitura(IDFornitore);
CREATE INDEX idx_gestione_responsabile ON Gestione(IDResponsabile);
CREATE INDEX idx_gestione_servizio ON Gestione(IDServizioCritico);
CREATE INDEX idx_supporto_servizio ON Supporto(IDServizioCritico);
CREATE INDEX idx_supporto_asset ON Supporto(IDAsset);
CREATE INDEX idx_appalto_fornitore ON Appalto(IDFornitore);
CREATE INDEX idx_appalto_asset ON Appalto(IDAsset);

-- TRIGGER PER VERSIONING E STORICO DELLE MODIFICHE
CREATE OR REPLACE FUNCTION gestisci_storico_e_versione()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO StoricoModifiche (
        TabellaOrigine, IDRecord, Operazione, VersioneStorica, DatiPrecedenti
    ) VALUES (
        TG_TABLE_NAME,
        (to_jsonb(OLD) ->> TG_ARGV[0])::INT,
        TG_OP,
        OLD.Versione,
        to_jsonb(OLD)
    );

    IF TG_OP = 'UPDATE' THEN
        NEW.Versione = OLD.Versione + 1;
        NEW.DataUltimoAggiornamento = CURRENT_TIMESTAMP;
        RETURN NEW;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_storico_soggettonis2
BEFORE UPDATE OR DELETE ON SoggettoNIS2
FOR EACH ROW EXECUTE FUNCTION gestisci_storico_e_versione('idsoggettonis2');

CREATE TRIGGER trg_storico_responsabile
BEFORE UPDATE OR DELETE ON Responsabile
FOR EACH ROW EXECUTE FUNCTION gestisci_storico_e_versione('idresponsabile');

CREATE TRIGGER trg_storico_serviziocritico
BEFORE UPDATE OR DELETE ON ServizioCritico
FOR EACH ROW EXECUTE FUNCTION gestisci_storico_e_versione('idserviziocritico');

CREATE TRIGGER trg_storico_asset
BEFORE UPDATE OR DELETE ON Asset
FOR EACH ROW EXECUTE FUNCTION gestisci_storico_e_versione('idasset');

CREATE TRIGGER trg_storico_fornitore
BEFORE UPDATE OR DELETE ON Fornitore
FOR EACH ROW EXECUTE FUNCTION gestisci_storico_e_versione('idfornitore');

-- METADATI E SPECIFICHE
COMMENT ON COLUMN SoggettoNIS2.CodiceIdentificativo IS 'Partita IVA (nazionale o UE) per soggetti privati o Codice IPA / Codice Fiscale per enti pubblici';
COMMENT ON COLUMN SoggettoNIS2.CodiceATECO IS 'Codice classificazione attività economica (standard ATECO italiano o NACE europeo)';
COMMENT ON COLUMN SoggettoNIS2.SettoreCriticita IS 'Macro-categoria del settore di appartenenza secondo il perimetro ACN (Settore Altamente Critico, Settore Critico, Altra Tipologia di Soggetto)';
COMMENT ON COLUMN SoggettoNIS2.TipologiaNIS2 IS 'Classificazione normativa del soggetto secondo la Direttiva NIS2 (Essenziale o Importante)';
COMMENT ON COLUMN Responsabile.SedeDiRiferimento IS 'Indirizzo completo della sede operativa (formato: Stato, Città, Via/Piazza, Numero Civico, CAP)';
COMMENT ON COLUMN ServizioCritico.MacroArea IS 'Comparto specifico disciplinato dagli allegati della normativa NIS2 (es. Infrastrutture IT, Servizi di rete, ...)';
COMMENT ON COLUMN ServizioCritico.CategoriaDiRilevanza IS 'Priorità di ripristino del servizio secondo dominio discreto condiviso (Critico, Alto, Medio, Basso)';
COMMENT ON COLUMN Asset.StatoOperativo IS 'Stato del ciclo di vita dell''asset (es. In produzione, In manutenzione, Dismesso, ...)';
COMMENT ON COLUMN Asset.CriticitaOperativa IS 'Impatto operativo in caso di disservizio del componente (Critico, Alto, Medio, Basso)';
COMMENT ON COLUMN Fornitore.CodiceIdentificativo IS 'Identificativo univoco del fornitore secondo gli stessi criteri di SoggettoNIS2.CodiceIdentificativo: Partita IVA (nazionale o UE) per soggetti privati oppure Codice IPA per enti pubblici';
COMMENT ON COLUMN Fornitore.ContattoReferente IS 'Recapito diretto del rappresentante, espresso come numero di telefono oppure indirizzo email';
COMMENT ON COLUMN Fornitore.SedeLegale IS 'Sede legale di riferimento del fornitore, strutturata secondo gli stessi criteri di Responsabile.SedeDiRiferimento (Stato, Città, Via/Piazza, Numero Civico, CAP)';
COMMENT ON COLUMN Fornitore.TipologiaAccesso IS 'Modalità di accesso ai sistemi del soggetto NIS2 (es. Remoto, Presidio fisico, Nessun accesso diretto, ...)';
COMMENT ON COLUMN Fornitore.LivelloDiCriticita IS 'Indice di rischiosità della interazione con la terza parte (Critico, Alto, Medio, Basso)';
COMMENT ON TABLE StoricoModifiche IS 'Registro storico centralizzato che conserva in formato JSONB lo stato precedente dei record modificati o eliminati';
