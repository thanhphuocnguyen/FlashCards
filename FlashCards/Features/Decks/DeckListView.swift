//
//  ContentView.swift
//  FlashCards
//
//  Created by Thành Phước Nguyễn on 19/11/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DeckListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Deck.createdAt, order: .reverse)
    private var decks: [Deck]
    
    @State private var isShowingNewDeck = false
    @State private var newDeckName = ""

    @State private var backupDocument: BackupDocument?
    @State private var isExportingBackup = false
    @State private var isShowingExportError = false

    @State private var isImportingBackup = false
    @State private var isShowingImportError = false
    @State private var isShowingImportSuccess = false
    @State private var importedDecks = 0
    @State private var importedCards = 0

    @State private var deckToDelete: Deck?
    @State private var isConfirmingDeckDelete = false
    
    private struct CardContentKey: Hashable {
        let front: String
        let back: String
        let vocabTypeRawVal: String?
        
        init(front: String, back: String, vocabTypeRawVal: String?) {
            self.front = front.trimmingCharacters(in: .whitespacesAndNewlines)
            self.back = back.trimmingCharacters(in: .whitespacesAndNewlines)
            self.vocabTypeRawVal = vocabTypeRawVal
        }
    }
    
    var body: some View {
        NavigationStack {
            List(decks) { deck in
                DeckRow(deck: deck) {
                    deckToDelete = deck
                    isConfirmingDeckDelete = true
                }
            }
            .navigationTitle("Decks")
            .toolbar {
                deckToolbar
            }
            .alert("New Deck", isPresented: $isShowingNewDeck) {
                TextField("Deck Name", text: $newDeckName)
                Button("Cancel", role: .cancel) {}
                Button("Create") {
                    createDeck()
                }
            }
            
            .fileExporter(
                isPresented: $isExportingBackup,
                document: backupDocument,
                contentType: .json,
                defaultFilename: "FlashCards-Backup"
            ) { result in
                if case .failure = result {
                    isShowingExportError = true
                }
            }
            .alert("Couldn't export backup", isPresented: $isShowingExportError) {
                Button("OK", role: .cancel) {}
            }
            .fileImporter(
                isPresented: $isImportingBackup,
                allowedContentTypes: [.json]
            ) { result in
                do {
                    try importBackup(from: result.get())
                } catch {
                    isShowingImportError = true
                }
            }
            .alert("Couldn't import backup", isPresented: $isShowingImportError) {
                Button("OK", role: .cancel) {}
            }
            .alert("Imported \(importedDecks) decks and \(importedCards) cards", isPresented: $isShowingImportSuccess) {
                Button("OK", role: .cancel) {}
                
            }
            .alert("Delete this deck?", isPresented: $isConfirmingDeckDelete, presenting: deckToDelete) { deck in
                Button("Cancel", role: .cancel) {
                    deckToDelete = nil
                }
                Button("Delete Deck", role: .destructive) {
                    modelContext.delete(deck)
                    deckToDelete = nil
                }
            } message: { deck in
                Text("“\(deck.name)” and all \(deck.cards.count) of its cards will be deleted.")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var deckToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("New Deck", systemImage: "plus") {
                newDeckName = ""
                isShowingNewDeck = true
            }
        }
        ToolbarItem(placement: .topBarLeading) {
            Menu("Backup") {
                Button("Export Backup") {
                    guard !decks.isEmpty else { return }
                    do {
                        try prepareBackupIDs()
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let data = try encoder.encode(FlashcardsBackup(decks: decks))
                        backupDocument = BackupDocument(data: data)
                        isExportingBackup = true
                    } catch {
                        isShowingExportError = true
                    }
                }
                
                Button("Import Backup") {
                    isImportingBackup = true
                    
                }
            }
        }
    }
    
    private func createDeck() {
        let name = newDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        modelContext.insert(Deck(name: name))
    }
    
    private func importBackup(from url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw CocoaError(.fileReadNoPermission)
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: url)
        let backup = try JSONDecoder().decode(FlashcardsBackup.self, from: data)
        
        guard backup.version == 1 || backup.version == 2 else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }
        
        try restoreDecks(from: backup)
    }
    
    private func restoreDecks(from backup: FlashcardsBackup) throws {
        try modelContext.save()
        var decksByBackupID: [UUID: Deck] = [:]
        for deck in decks {
            if let id = deck.backupID {
                decksByBackupID[id] = deck
            }
        }
        var addedDeckCount = 0
        var addedCardCount = 0
        for snapshot in backup.decks {
            // if deck existed in user's list
            if let id = snapshot.backupID,
               let existingDeck = decksByBackupID[id] {
                var knownCardIDs = Set(existingDeck.cards.compactMap(\.backupID))
                var knownContent = Set(existingDeck.cards.map { card in
                    CardContentKey(
                        front: card.front,
                        back: card.back,
                        vocabTypeRawVal: card.vocabTypeRawVal
                    )
                })
                
                // handle for cards had ids
                for savedCard in snapshot.cards {
                    guard let cardID = savedCard.backupID,
                          knownCardIDs.insert(cardID).inserted else { continue }
                    
                    existingDeck.cards.append(makeCard(from: savedCard))
                    knownContent.insert(CardContentKey(
                        front: savedCard.front,
                        back: savedCard.back,
                        vocabTypeRawVal: savedCard.vocabTypeRawVal
                    ))

                    addedCardCount+=1
                }
                
                // handle for cards didn't contain id
                for savedCard in snapshot.cards where savedCard.backupID == nil {
                    let key = CardContentKey(
                        front: savedCard.front,
                        back: savedCard.back,
                        vocabTypeRawVal: savedCard.vocabTypeRawVal
                    )
                    
                    guard knownContent.insert(key).inserted else { continue }
                    
                    existingDeck.cards.append(makeCard(from: savedCard))
                    addedCardCount += 1
                }

                continue
            }

            // handle for new deck
            var seenCardIDs = Set<UUID>()
            // filter cards that weren't added
            let cards = snapshot.cards.compactMap { savedCard -> Flashcard? in
                if let id = savedCard.backupID,
                   !seenCardIDs.insert(id).inserted {
                    return nil
                }
                return  makeCard(from: savedCard)
            }
            
            // create new deck
            let deck = Deck(name: snapshot.name, cards: cards)
            deck.createdAt = snapshot.createdAt
            deck.backupID = snapshot.backupID ?? deck.backupID
            deck.primaryLanguageCode = snapshot.primaryLanguageCode
            decksByBackupID[deck.backupID!] = deck

            addedDeckCount+=1
            addedCardCount += cards.count
            
            modelContext.insert(deck)
        }
        
        // make a transaction
        do {
            try modelContext.save()
            isShowingImportSuccess = true
            importedDecks = addedDeckCount
            importedCards = addedCardCount
        } catch {
            modelContext.rollback()
            throw error
        }
    }
    
    private func prepareBackupIDs() throws {
        for deck in decks {
            if deck.backupID == nil {
                deck.backupID = UUID()
            }
            
            for card in deck.cards where card.backupID == nil {
                card.backupID = UUID()
            }
        }
        
        try modelContext.save()
    }
    
    private func makeCard(from snapshot: FlashcardsBackup.CardSnapshot) -> Flashcard {
        let card = Flashcard(front: snapshot.front, back: snapshot.back)
        card.backupID = snapshot.backupID ?? card.backupID
        card.nextReviewAt = snapshot.nextReviewAt
        card.intervalDays = snapshot.intervalDays
        card.vocabTypeRawVal = snapshot.vocabTypeRawVal
        return card
    }
}

#Preview {
    DeckListView()
        .modelContainer(for: [Deck.self, Flashcard.self], inMemory: true)
}
