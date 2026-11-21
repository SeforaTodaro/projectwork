-- CREAZIONE DELLA VIEW PER IL PROFILO DI CONFORMITÀ ACN
-- Aggrega anagrafica, responsabili, servizi critici, asset e fornitori per ciascun soggetto NIS2 evitando duplicazioni
-- Blocco di codice eseguito per primo per esportare il file profilo_acn.csv 
CREATE OR REPLACE VIEW v_profilo_acn AS
SELECT
    s.IDSoggettoNIS2,
    s.RagioneSociale,
    s.CodiceIdentificativo,
    s.CodiceATECO,
    s.DomicilioDigitale,
    s.SettoreCriticita,
    s.TipologiaNIS2,
    s.UbicazioneSedeStatoUE || ', ' || s.UbicazioneSedeCitta || ', ' ||
        s.UbicazioneSedeVia || ' ' || COALESCE(s.UbicazioneSedeNumeroCivico, 'snc') ||
        ', ' || s.UbicazioneSedeCAP AS SedeLegaleCompleta,
    s.Versione AS VersioneProfilo,
    COUNT(DISTINCT r.IDResponsabile) AS TotaleResponsabili,
    STRING_AGG(DISTINCT r.Nome || ' ' || r.Cognome || ' (' || r.TitoloGiuridico || ' - ' || r.ContattoEmail || ')', '; ') AS ReferentiDesignati,
    COUNT(DISTINCT sc.IDServizioCritico) AS TotaleServiziCritici,
    STRING_AGG(DISTINCT sc.Nome || ' [' || sc.CategoriaDiRilevanza || ']', '; ') AS ServiziEssenzialiCritici,
    COUNT(DISTINCT a.IDAsset) AS TotaleAsset,
    STRING_AGG(DISTINCT a.Nome || ' (' || a.Tipologia || ' - ' || a.CriticitaOperativa || ')', '; ') AS InventarioAsset,
    COUNT(DISTINCT f.IDFornitore) AS TotaleFornitori,
    STRING_AGG(DISTINCT f.RagioneSociale || ' [' || f.TipologiaAccesso || ' - Rischio: ' || f.LivelloDiCriticita || ']', '; ') AS FornitoriTerzeParti
FROM SoggettoNIS2 s
LEFT JOIN Responsabile r ON s.IDSoggettoNIS2 = r.IDSoggettoNIS2
LEFT JOIN ServizioCritico sc ON s.IDSoggettoNIS2 = sc.IDSoggettoNIS2
LEFT JOIN Asset a ON s.IDSoggettoNIS2 = a.IDSoggettoNIS2
LEFT JOIN Fornitura fo ON s.IDSoggettoNIS2 = fo.IDSoggettoNIS2
LEFT JOIN Fornitore f ON fo.IDFornitore = f.IDFornitore
GROUP BY s.IDSoggettoNIS2;
SELECT * FROM v_profilo_acn;

-- QUERY 2: CATENA DI DIPENDENZA CRITICA
-- Individua quali terze parti operano direttamente sugli asset che sostengono i servizi essenziali
-- Query eseguita come seconda e salvata nel file catena_dipendenze.csv
SELECT
    s.RagioneSociale AS SoggettoNIS2,
    s.TipologiaNIS2,
    sc.Nome AS ServizioCritico,
    sc.CategoriaDiRilevanza AS RilevanzaServizio,
    a.Nome AS AssetCoinvolto,
    a.CriticitaOperativa AS CriticitaAsset,
    f.RagioneSociale AS FornitoreInAppalto,
    f.TipologiaAccesso,
    f.LivelloDiCriticita AS RischioFornitore
FROM SoggettoNIS2 s
JOIN ServizioCritico sc ON s.IDSoggettoNIS2 = sc.IDSoggettoNIS2
JOIN Supporto sup ON sc.IDServizioCritico = sup.IDServizioCritico
JOIN Asset a ON sup.IDAsset = a.IDAsset
LEFT JOIN Appalto app ON a.IDAsset = app.IDAsset
LEFT JOIN Fornitore f ON app.IDFornitore = f.IDFornitore
ORDER BY s.RagioneSociale, sc.Nome, a.Nome;

-- QUERY 3: ANALISI DEL RISCHIO SUPPLY CHAIN
-- Fornitori con accesso remoto o fisico su asset Critici/Alti
--Query eseguita come terza per esportarla come rischio_supply_chain.csv
SELECT
    s.RagioneSociale AS SoggettoNIS2,
    f.RagioneSociale AS Fornitore,
    f.TipologiaFornitura,
    f.TipologiaAccesso,
    f.LivelloDiCriticita AS RischioFornitore,
    a.Nome AS AssetGestito,
    a.SpazioDiIndirizzamento,
    a.CriticitaOperativa AS CriticitaAsset
FROM Fornitore f
JOIN Appalto app ON f.IDFornitore = app.IDFornitore
JOIN Asset a ON app.IDAsset = a.IDAsset
JOIN SoggettoNIS2 s ON a.IDSoggettoNIS2 = s.IDSoggettoNIS2
WHERE f.TipologiaAccesso IN ('Remoto', 'Presidio fisico')
  AND a.CriticitaOperativa IN ('Critico', 'Alto')
ORDER BY a.CriticitaOperativa, f.RagioneSociale;

-- QUERY 4: Matrice di Governance e responsabilità in caso di incidente CSIRT/ACN
-- Eseguita come quarta ed esportata come governance.csv
SELECT
    s.RagioneSociale AS SoggettoNIS2,
    sc.Nome AS ServizioCritico,
    sc.MacroArea,
    sc.CategoriaDiRilevanza,
    r.Nome || ' ' || r.Cognome AS Responsabile,
    r.RuoloAziendale,
    r.TitoloGiuridico,
    r.ContattoEmail,
    r.ContattoTelefonico
FROM Responsabile r
JOIN Gestione g ON r.IDResponsabile = g.IDResponsabile
JOIN ServizioCritico sc ON g.IDServizioCritico = sc.IDServizioCritico
JOIN SoggettoNIS2 s ON sc.IDSoggettoNIS2 = s.IDSoggettoNIS2
ORDER BY s.RagioneSociale, sc.CategoriaDiRilevanza;

-- TEST DEL TRIGGER DI VERSIONING E AUDIT LOG (JSONB)
-- Blocco unico di codice eseguito come ultimo e salvato come test_storico_modifiche.csv
-- Passo 1: Simulazione di una rivalutazione del rischio su un asset (da 'Medio' a 'Alto')
UPDATE Asset
SET CriticitaOperativa = 'Alto'
WHERE Nome = 'Gateway Pagamenti SEPA';

-- Passo 2: Verifica che la versione corrente sia salita a 2
SELECT IDAsset, Nome, CriticitaOperativa, Versione, DataUltimoAggiornamento
FROM Asset
WHERE Nome = 'Gateway Pagamenti SEPA';

-- Passo 3: Verifica che il trigger abbia salvato in JSONB lo stato precedente (Versione 1)
SELECT
    IDStorico,
    TabellaOrigine,
    IDRecord,
    Operazione,
    VersioneStorica,
    DatiPrecedenti ->> 'nome' AS NomeAssetStorico,
    DatiPrecedenti ->> 'criticitaoperativa' AS CriticitaPrecedente,
    DatiPrecedenti AS SnapshotCompletoJSONB,
    DataModifica
FROM StoricoModifiche;