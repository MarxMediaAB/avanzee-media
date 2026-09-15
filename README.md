# Avanzee Medien und Warteschlange

Öffentlicher Speicher für die Instagram-Automatik von **@avanzeelife_de**.

Instagram lädt Videos nicht hoch, es holt sie über eine öffentliche URL ab
(`video_url`). Das Hauptrepository `MarxMediaAB/avanzee_2` ist privat, seine
`raw.githubusercontent.com`-Adressen geben anonym 404 zurück und sind für Meta
damit unerreichbar. Deshalb liegen die fertigen Medien hier.

Hier liegt nur Material, das ohnehin öffentlich wird. Kein Quellcode der
Website, keine Schlüssel, keine Kundendaten.

## Aufbau

```
reels/       <id>.mp4 und <id>.txt (Caption) je Stück
karussell/   K1-ziele-scheitern-1.png bis -6.png plus .txt
vorschau/    <id>.jpg, kleines Standbild der ersten Karte für das Review-Board
queue.json   Veröffentlichungsplan: was geht wann raus, was ist schon raus
```

Adressen, die Meta abholt:

```
https://raw.githubusercontent.com/MarxMediaAB/avanzee-media/main/reels/<id>.mp4
https://raw.githubusercontent.com/MarxMediaAB/avanzee-media/main/reels/<id>.txt
```

## queue.json

Ein Eintrag pro Tag unter `posts`, aufsteigend nach Datum.

| Feld | Bedeutung |
|---|---|
| `date` | Veröffentlichungstag, Europe/Berlin, 18:00 |
| `id` | Dateiname ohne Endung, zeigt auf `reels/<id>.mp4` und `.txt` |
| `status` | `queued` oder `posted`. Nur `queued` wird veröffentlicht |
| `modus` | `manuell` (Normalfall), `auto` (nur auf Toms Wort), `umbau` (noch nicht fertig) |
| `media_id`, `permalink`, `posted_at` | nach dem Posten eingetragen |

`modus: manuell` ist seit dem 15.09.2026 der Normalfall: nicht veröffentlichen,
sondern Tom Video und Caption schicken. Er lädt in der App hoch und legt dort
Trending-Audio darauf. Über die API lässt sich keine Musik hinzufügen, und
nachträglich geht es in der App auch nicht mehr, deshalb muss der Ton beim
Erstellen des Beitrags dazukommen.

`auto` wird nur gesetzt, wenn Tom für ein Stück ausdrücklich "stumm posten"
sagt. `umbau` heißt: noch nicht fertig, überspringen.

Fällt das Stück des Tages aus, rückt der nächste Eintrag mit `queued` nach,
damit die Kette nicht reißt.

## Harte Regeln

Diese Regeln gelten für jedes Stück und sind nicht verhandelbar.

1. **Kein Post ohne vollständige Caption.** Fehlt die `.txt`, wird nicht gepostet.
2. **Genau fünf Hashtags** pro Caption. Nie mehr, nie weniger. Keine Markentags:
   `#avanzee` und `#nordstern` bringen keine Verteilung und verschwenden einen
   Platz. Zwei Anker (`#persönlichkeitsentwicklung`, `#selbstreflexion`), drei
   aus dem Thema.
3. **Ohne Tonspur.** Seit 14.09.2026 gehen alle Videos stumm raus. Tom legt
   Trending-Audio in der App darauf, und eine vorhandene Tonspur verhindert das.
4. **Logo und AVANZEE.COM auf jedem Bild.** Bei Reels oben mittig, weil Instagram
   die unteren rund 300 Pixel mit der eigenen Oberfläche überdeckt. Beim
   Karussell unten.
5. **CTA ist der Bio-Link**, `avanzee.com/lt`. Seit 14.09.2026 wird nicht mehr
   zum Kommentieren aufgefordert.
6. **Deutsch in Toms Ton**, Anrede durchgehend klein.
7. **Captions werden nie verändert**, weder vor noch nach dem Posten. Über die
   API lässt sich eine Caption ohnehin nicht nachträglich ändern und ein Beitrag
   nicht löschen, beides geht nur in der App.

## Ablauf der Veröffentlichung

1. Eintrag mit dem heutigen Datum aus `queue.json` nehmen.
2. Caption von der raw-URL laden und die fünf Hashtags prüfen.
3. `INSTAGRAM_POST_IG_USER_MEDIA` mit `media_type: REELS` und der raw-URL als
   `video_url` erzeugt den Container.
4. `INSTAGRAM_GET_POST_STATUS` mit `creation_id` pollen bis `FINISHED`.
5. `INSTAGRAM_POST_IG_USER_MEDIA_PUBLISH` veröffentlicht.
6. `media_id`, `permalink`, `posted_at` eintragen, `status` auf `posted`, die
   geänderte `queue.json` committen und pushen.

Ein unveröffentlichter Container ist in der App unsichtbar und verfällt nach
weniger als 24 Stunden, eignet sich also für einen Trockenlauf.

## Zahlen

Reichweite und Views sind über `INSTAGRAM_GET_IG_MEDIA_INSIGHTS` abrufbar
(`views`, `reach`, `shares`, `saved`, `likes`, `comments`), trotz der in der
Dokumentation genannten Schwelle von 1000 Followern. Likes allein sind bei
dieser Kontogröße kein brauchbares Signal.
