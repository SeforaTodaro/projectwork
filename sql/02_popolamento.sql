-- POPOLAMENTO TABELLE INDIPENDENTI
INSERT INTO SoggettoNIS2 (
    RagioneSociale, CodiceIdentificativo, CodiceATECO, DomicilioDigitale,
    SettoreCriticita, TipologiaNIS2, UbicazioneSedeStatoUE,
    UbicazioneSedeCitta, UbicazioneSedeVia, UbicazioneSedeNumeroCivico, UbicazioneSedeCAP
) VALUES
(
    'Gruppo Ospedaliero Alpha S.p.A.', 'Partita IVA 12345678910', '86.10.00',
    'direzione@pec.gruppoalphaospedali.it', 'Settore Altamente Critico', 'Essenziale',
    'Italia', 'Milano', 'Viale Urano', '198', '20121'
),
(
    'Banca di Credito Cooperativo Beta S.p.A.', 'Partita IVA 11223344556', '64.19.10',
    'segreteria@pec.bccbeta.it', 'Settore Altamente Critico', 'Importante',
    'Italia', 'Bologna', 'Via Nettuno', '154', '40121'
);

INSERT INTO Fornitore (
    RagioneSociale, CodiceIdentificativo, ContattoReferente, SedeLegale,
    TipologiaFornitura, TipologiaAccesso, LivelloDiCriticita
) VALUES
(
    'Gamma CyberDefense S.r.l.', 'Partita IVA 11122233344', 'referente@gammacyber.it',
    'Italia, Torino, Corso di Venere, 65, 10128',
    'SOC 24/7 e Sicurezza Perimetrale', 'Remoto', 'Critico'
),
(
    'Delta Sistemi & Hardware S.r.l.', 'Partita IVA 11112222333', 'infos@pec.deltasistemi.it',
    'Italia, Monza, Piazza Marte, 92, 20900',
    'Manutenzione Hardware Server e Storage in Sala CED', 'Presidio fisico', 'Alto'
),
(
    'Epsilon Cloud & Backup S.r.l.', 'Partita IVA 11111222223', 'supporto@epsiloncloud.it',
    'Italia, Firenze, Viale Saturno, 12, 50123',
    'Backup Off-Site e Disaster Recovery', 'Nessun accesso diretto', 'Medio'
);

-- POPOLAMENTO TABELLE DIPENDENTI 
INSERT INTO Responsabile (
    CodiceFiscale, Nome, Cognome, ContattoEmail, ContattoTelefonico,
    RuoloAziendale, TitoloGiuridico, SedeDiRiferimento, IDSoggettoNIS2
) VALUES
(
    'VRDFRZ78C15F205X', 'Fabrizio', 'Verdi', 'f.verdi@gruppoalphaospedali.it', '+39 02 12345678',
    'CISO - Responsabile Sicurezza Informatica', 'Punto di contatto ACN',
    'Italia, Milano, Viale Urano, 198, 20121', 1
),
(
    'BNCLSS84P52F205Y', 'Alessia', 'Bianchi', 'a.bianchi@gruppoalphaospedali.it', '+39 02 11223344',
    'Direttore Sistemi Informativi Clinici', 'Referente CSIRT',
    'Italia, Milano, Viale Urano, 198, 20121', 1
),
(
    'GLLGNN75D10A944K', 'Giovanni', 'Gialli', 'g.gialli@bccbeta.it', '+39 051 1112223',
    'Responsabile Sicurezza ICT e Continuità Operativa', 'Punto di contatto ACN',
    'Italia, Bologna, Via Nettuno, 154, 40121', 2
);

INSERT INTO ServizioCritico (
    Nome, Descrizione, MacroArea, CategoriaDiRilevanza, IDSoggettoNIS2
) VALUES
(
    'Pronto Soccorso e Triage Digitale',
    'Gestione accettazione emergenze, cartelle cliniche di urgenza e refertazione rapida',
    'Assistenza Sanitaria Ospedaliera', 'Critico', 1
),
(
    'Diagnostica per Immagini (PACS/RIS)',
    'Archiviazione e trasmissione referti radiologici e sale operatorie',
    'Infrastrutture IT e Banche Dati Cliniche', 'Alto', 1
),
(
    'Core Banking e Pagamenti Interbancari SEPA',
    'Gestione conti correnti, bonifici istantanei e circuiti di pagamento elettronico',
    'Settore Bancario e Servizi Finanziari', 'Alto', 2
);

INSERT INTO Asset (
    Nome, Tipologia, StatoOperativo, SpazioDiIndirizzamento, CriticitaOperativa, IDSoggettoNIS2
) VALUES
(
    'Cluster Cartella Clinica 01', 'Server Virtuale', 'In produzione', '10.20.10.0/24', 'Critico', 1
),
(
    'Storage PACS Radiologia', 'Sistema Storage SAN', 'In produzione', '10.20.30.0/24', 'Alto', 1
),
(
    'Firewall Core Ospedale', 'Apparato di Rete', 'In produzione', '192.168.100.1/32', 'Critico', 1
),
(
    'Server Legacy Archivio 01', 'Server Fisico', 'Dismesso', 'Non in rete', 'Basso', 1
),
(
    'Mainframe Core Banking 01', 'Server Mainframe', 'In produzione', '10.50.10.0/24', 'Critico', 2
),
(
    'Gateway Pagamenti SEPA', 'Server Applicativo', 'In produzione', '10.50.20.0/24', 'Medio', 2
);

-- POPOLAMENTO TABELLE ASSOCIATIVE (RELAZIONI N:M)
INSERT INTO Fornitura (IDSoggettoNIS2, IDFornitore) VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 3);

INSERT INTO Gestione (IDResponsabile, IDServizioCritico) VALUES
(1, 1),
(2, 1),
(2, 2),
(3, 3);

INSERT INTO Supporto (IDServizioCritico, IDAsset) VALUES
(1, 1),
(1, 3),
(2, 2),
(2, 3),
(3, 5),
(3, 6);

INSERT INTO Appalto (IDFornitore, IDAsset) VALUES
(1, 3),
(2, 2),
(1, 6),
(3, 6);