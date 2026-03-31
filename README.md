# App – Gestione Decentralizzata Dati Sanitari

Applicazione mobile Flutter per la raccolta, cifratura e condivisione sicura di dati sanitari personali. I dati vengono cifrati sul dispositivo e archiviati su IPFS; la loro integrità viene ancorata su blockchain Ethereum.

## Architettura

```
Dispositivo mobile (HealthKit / Health Connect)
    │
    ▼
AES-256-GCM (cifratura locale)
    │
    ▼
Backend relay ──► IPFS (Web3.Storage)
               ──► Ethereum Sepolia (AnchorRegistry)
```

La chiave di cifratura (DEK) è derivata tramite HKDF-SHA256 da una chiave radice (KEK) protetta nel secure storage del dispositivo. L'identità dell'utente è basata su una coppia di chiavi Ed25519 e un indirizzo Ethereum (secp256k1).

## Requisiti

- **Flutter** >= 3.19 con Dart SDK >= 3.3
- **Xcode** (per build iOS) oppure **Android Studio** (per build Android)
- Testato su iPhone 15 (iOS 17) e dispositivo Android
- Backend in esecuzione (vedi `../sorgentibackendtesi/`)

## Installazione

```bash
flutter pub get
```

### Configurazione backend

L'URL del backend è definito in due posti:

- `lib/main.dart` → `kBackendBaseUrl`
- `lib/services/directory_service.dart` → `baseUrl`

Aggiorna entrambi con l'indirizzo del tuo server:

```dart
// lib/main.dart
static const String kBackendBaseUrl = 'http://TUO_SERVER:8787';

// lib/services/directory_service.dart
static const String baseUrl = 'http://TUO_SERVER:8787';
```

## Avvio

```bash
# Su simulatore iOS
flutter run

# Su emulatore Android
flutter run

# Su dispositivo fisico iOS (richiede Xcode e provisioning)
flutter run --release

# Su dispositivo fisico Android
flutter run --release
```

## Funzionalità principali

- **Raccolta dati sanitari**: lettura di passi, frequenza cardiaca, ossigeno nel sangue e sonno tramite HealthKit (iOS) e Health Connect (Android)
- **Cifratura locale**: ogni record è cifrato con AES-256-GCM prima di lasciare il dispositivo
- **Upload IPFS**: i dati cifrati vengono caricati su IPFS tramite il backend relay, che restituisce un CID immutabile
- **Ancoraggio blockchain**: l'hash del manifest viene registrato su Ethereum Sepolia tramite il contratto `AnchorRegistry` con il pattern relay (firma off-chain ECDSA dell'utente)
- **Condivisione sicura**: il proprietario può condividere i propri dati con altri utenti generando una grant cifrata con la chiave pubblica del destinatario (ECDH X25519 + AES-GCM key wrap)
- **Verifica integrità**: ogni manifest è firmato con Ed25519 prima dell'upload

## Struttura del codice

```
lib/
├── main.dart                  # Entry point e routing dell'applicazione
├── crypto/
│   ├── encryption_service.dart  # AES-256-GCM, HKDF, cifratura record
│   ├── key_manager.dart         # Gestione KEK e DEK (secure storage)
│   ├── identity_service.dart    # Chiavi Ed25519 e secp256k1 dell'utente
│   └── wrap_service.dart        # Key wrap/unwrap DEK per la condivisione
├── services/
│   ├── ipfs_client.dart         # Upload manifest e file su IPFS via backend
│   ├── directory_client.dart    # Lettura directory pubblica utenti
│   ├── directory_service.dart   # Registrazione chiavi pubbliche
│   ├── crypto_benchmark.dart    # Suite di benchmark crittografici
│   └── timing_logger.dart       # Raccolta timing per benchmark
├── models/
│   └── ...                      # Modelli dati (record sanitari, manifest, grant)
├── pages/
│   ├── shared_with_me_page.dart # Visualizzazione dati condivisi da altri utenti
│   └── ...                      # Altre schermate
├── payload/
│   └── ...                      # Strutture dei payload inviati al backend
└── theme/
    └── app_theme.dart           # Tema grafico dell'applicazione
```

## Dipendenze principali

| Pacchetto | Uso |
|-----------|-----|
| `health` | Lettura dati da HealthKit (iOS) e Health Connect (Android) |
| `cryptography` | AES-256-GCM, HKDF-SHA256, Ed25519, X25519 |
| `flutter_secure_storage` | Archiviazione sicura delle chiavi (Keychain su iOS, Keystore su Android) |
| `web3dart` | Firma transazioni Ethereum (secp256k1) |
| `dio` / `http` | Chiamate HTTP al backend |
| `shared_preferences` | Preferenze locali non sensibili |

## Note

- L'app è stata testata su **iOS** (iPhone 15, iOS 17) e **Android**.
- I dati sanitari non vengono mai inviati in chiaro: la cifratura avviene interamente sul dispositivo prima di qualsiasi comunicazione di rete.
- Il file `logbenchmarkcompleto.csv` nella root contiene i dati di benchmark delle operazioni crittografiche raccolti durante i test su iPhone 15.
