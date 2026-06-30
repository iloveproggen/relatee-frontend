# Refactor Action Plan (Grundlegend)

## Zielbild
- Monolithische Verantwortlichkeiten aus UI-Dateien entkoppeln.
- Globale Mutable-States systematisch zentralisieren.
- Netzwerk-/GraphQL-Aufrufe in Services bündeln.
- Logging, Timeouts und Endpoints vereinheitlichen.
- Schrittweise, kompatible Migration ohne Feature-Bruch.

## Phasen
- [x] Phase 0: Basis gelegt
  - [x] Core-Module angelegt (constants, logging, network, task utils/service, color utils)
  - [x] main auf Core-Factory/Utils umgestellt (kompatibel)
- [x] Phase 1: AppState zentralisieren
  - [x] Globalen Zustand in eigenes State-Modul verschieben
  - [x] Kompatible Getter/Setter in main beibehalten
- [x] Phase 2: Reward-Domain entkoppeln
  - [x] Reward-GraphQL in dedizierten Service verschieben
  - [x] shop.dart auf Service API umstellen
- [x] Phase 3: Households/Tasks weiter zerlegen
  - [x] Household-Query-/Mapping in eigenen Service extrahieren
  - [x] Screen-Dateien von Mapping/Transportdetails entlasten
- [ ] Phase 4: Verifikation & Cleanup
  - [x] Analyzer/Fehlercheck
  - [~] Ungenutzte Helfer/Imports bereinigen (fortlaufend)
  - [x] Restliche Debug-Prints in Kernfluss (main/shop) auf Logger umgestellt
  - [x] Shop-Globalstate (coins/updateShop) in Widget-State verschoben
  - [x] Signup-Flow auf zentrale Endpoints/Logger umgestellt
  - [x] Legacy-Print-Nester bereinigt in create_new_task_v1, detailed_task_view, household_tasks, join_household
  - [x] Breite Logger-Migration in weiteren Legacy-Screens (u.a. completed/reward/routine/profile/settings/login)
  - [x] Weitere globale UI-States reduziert (leader_board_v2, join_household, login)
  - [x] Vollständiger Stabilitäts-Pass mit flutter analyze (keine Analyzer-Errors)

## Abnahme-Kriterien
- Keine Errors in lib
- Bestehende Navigation/Flows bleiben unverändert
- Infrastrukturcode liegt unter lib/core
