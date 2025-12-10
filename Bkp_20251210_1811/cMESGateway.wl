// cMESGateway – einfache GraphQL‑Anbindung an MES Gateway
// Getestet mit WinDev 2025 (Englische Oberfläche)

// -----------------------------------------------------------------
// Klassendeklaration
// -----------------------------------------------------------------
CLASS cMESGateway
PRIVATE
	sBaseURL is string
PUBLIC
	// Konstruktor
	PROCEDURE Constructor(psBaseURL is string = "http://192.168.0.138:4000/graphql")

	// Liste aller Tabellen (GraphQL: query { tables })
	PROCEDURE GetTables() : string

	// Generische Zeilenabfrage für eine Tabelle
	// GraphQL: query { rows(table:"FilamentTypes", limit:100) }
	PROCEDURE GetRows(psTable is string, pnLimit is int = 100) : string

	// Komfortfunktionen für häufige Tabellen
	PROCEDURE GetFilamentTypes(pnLimit is int = 100) : string
	PROCEDURE GetFilamentSpools(pnLimit is int = 100) : string
	PROCEDURE GetPrinters(pnLimit is int = 100) : string
PRIVATE
	// interner Helper zum Senden einer GraphQL‑Query
	PROCEDURE _SendQuery(psQuery is string) : string
END

// -----------------------------------------------------------------
// Implementierung
// -----------------------------------------------------------------

// Konstruktor
PROCEDURE cMESGateway.Constructor(psBaseURL is string = "http://192.168.0.138:4000/graphql")
sBaseURL = psBaseURL

// Tabellenliste
PROCEDURE cMESGateway.GetTables() : string
sQuery is string = "query { tables }"
RESULT _SendQuery(sQuery)

// generische Zeilenabfrage
PROCEDURE cMESGateway.GetRows(psTable is string, pnLimit is int = 100) : string
// einfache Maskierung der Anführungszeichen im Tabellennamen
sTableEsc is string = Replace(psTable, """", "\""")
sLimit is string = NumToString(pnLimit)
sQuery is string = "query { rows(table:\"" + sTableEsc + "\", limit:" + sLimit + ") }"
RESULT _SendQuery(sQuery)

// Komfort – FilamentTypes
PROCEDURE cMESGateway.GetFilamentTypes(pnLimit is int = 100) : string
RESULT GetRows("FilamentTypes", pnLimit)

// Komfort – FilamentSpools
PROCEDURE cMESGateway.GetFilamentSpools(pnLimit is int = 100) : string
RESULT GetRows("FilamentSpools", pnLimit)

// Komfort – Printers
PROCEDURE cMESGateway.GetPrinters(pnLimit is int = 100) : string
RESULT GetRows("Printers", pnLimit)

// interner Helper
PROCEDURE cMESGateway._SendQuery(psQuery is string) : string
sBody is string
sBody = "{""query"":""" + psQuery + """,""variables"":{}}"

// HTTP‑Request ausführen
HTTPRequest("MES_GQL", sBaseURL, httpPost, sBody, "application/json")

IF ErrorOccurred THEN
	// Fehlertext zurückgeben – kann im Aufrufer geloggt / analysiert werden
	RESULT ErrorInfo(errFullDetails)
END

sResult is string = HTTPGetResult(httpResult)
RESULT sResult
