# Flutter Notifications Workshop

- Local Notifications: lokal auf dem Gerät geplant und ausgelöst
- Push Notifications: externe Dienste/Server (Firebase Cloud Messaging)

## Permission-Modelle

### iOS

- System-Permission-Dialog nur einmal möglich

- 5 Zustände:
    - notDetermined: Noch nie gefragt → System-Dialog möglich
    - authorized: Vollzugriff gewährt
    - provisional: Trial-Modus (iOS 12+) → Nur Notification Center, leise
    - denied: Permanent abgelehnt → Nur über Einstellungen änderbar
    - ephemeral: Temporär (nur App Clips)

### Android

-System Permissions 2x, dann endgültig

- Vor Android 12: Opt-out (standardmäßig aktiv)
- Ab Android 13: Opt-in (standardmäßig deaktiviert)
- Runtime Permission (POST_NOTIFICATIONS) nötig


## Notification channels 

### Android

- seit Android 8.0 müssen alle Notifications einem channel zugeordnet werden (ohne Chanel)
    - Nutzer können die Channels auswählen https://developer.android.com/develop/ui/views/notifications/channels
    

```dart
const AndroidNotificationChannel transactionChannel = AndroidNotificationChannel(
  'transactions',           
  'Bestellungen',           
  description: 'Updates zu deinen Bestellungen',
  importance: Importance.high,
);

const AndroidNotificationChannel marketingChannel = AndroidNotificationChannel(
  'marketing',
  'Angebote & News',
  description: 'Personalisierte Angebote und Neuigkeiten',
  importance: Importance.low,  
);
```

## iOS 

- Notifications categories (Vorlagen), die festlegen welche Aktions-Buttons eine Notification haben kann https://cocoacasts.com/actionable-notifications-with-the-user-notifications-framework


- Zustände
    - Foreground 
        - iOS: Notification wird nicht angezeigt - kann bei FCM anders konfiguriert werden
        - Android: Notification erscheint normal
    - Background 
        - iOS & Android: Notification erscheint, Tap Handler wird aufgerufen
    - Terminated 
        - iOS & Android: Notification erscheint, App wird bei Tap gestartet
    - Force Quit 
        - iOS: Silent Push weckt App NICHT auf
        - Android: Variiert stark nach OEM (Original Equipment Manufacturer)

- https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages (explizite Config)


# FCM 

```
Your Server → FCM Backend → Platform Transport (APNs/GCM) → Device → App
```

### Kernkonzepte

- FCM = Routing-Service, kein direkter Hardware-Zugriff
- FCM ist eine Abstraktionsschicht über den plattformspezifischen Diensten
- Für iOS: FCM leitet intern an Apple APNs weiter
- Für Android: FCM nutzt Google Cloud Messaging (GCM) Infrastruktur

### iOS-Besonderheit: APNs-Pflicht

- APNs (Apple Push Notification service) = einziger Weg zu iOS-Hardware
- Ohne APNs-Key in Firebase Console → keine iOS-Push-Notifications
- APNs kommuniziert mit Hardware-spezifischem Identifier

### FCM im iOS Simulator

- eigentlich nicht gedacht auf Simulator auszuführen  

**Workarounds für Simulator-Tests:**
- `.apns`-Payload-Dateien per Drag-and-Drop auf Simulator ziehen
- Terminal: `xcrun simctl push <device-id> <bundle-id> <payload.apns>`

- Artikel: https://medium.com/macoclock/push-notifications-to-ios-simulators-97622047f84e
---

## Token-Lifecycle

### Was ist ein FCM Token?

- Eindeutige "Adresse" eines Geräts für Push-Zustellung
- Wird von FCM generiert und verwaltet
- Nicht permanent – kann sich jederzeit ändern

### Wann ändert sich ein Token?

| Ereignis | Token-Änderung |
|----------|----------------|
| App-Neuinstallation | Neuer Token |
| App-Daten gelöscht | Neuer Token |
| Gerätewechsel / Wiederherstellung | Neuer Token |
| Periodischer FCM-Refresh | Neuer Token |
| 270 Tage Inaktivität (Android) | Token wird "stale" |

### Best Practices Token-Management

**Client-seitig:**
- Token bei jedem App-Start abrufen
- Mit lokal gespeichertem Token vergleichen
- Bei Änderung sofort an Backend senden
- `onTokenRefresh`-Listener implementieren

**Server-seitig:**
- Token mit Zeitstempel speichern
- User-ID mit Token verknüpfen
- Bei Zustellfehler (`InvalidRegistration`) Token löschen

---


### Packages und Quellen
- https://firebase.flutter.dev/docs/messaging/usage/
- https://firebase.google.com/docs/cloud-messaging/flutter/client
- https://developer.apple.com/documentation/usernotifications
- https://pub.dev/packages/flutter_local_notifications (lokal)
- https://fluttergems.dev/packages/awesome_notifications/ (lokal und push)
- https://pub.dev/packages/firebase_messaging (push)
- https://pub.dev/packages/onesignal_flutter (push)


