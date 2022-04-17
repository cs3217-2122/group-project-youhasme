//
//  MultiplayerRoomViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 16/4/22.
//

import Foundation

class MultiplayerEntryViewModel: ObservableObject {
    var storage = MultiplayerRoomStorage()
    @Published var displayName: String = ""
    @Published var joinCode: String = ""
    
    func joinRoom() async -> String? {
        do {
            let roomId = try await storage.joinRoom(joinCode: joinCode, displayName: displayName)
            return roomId
        } catch {
            print("Couldn't join a room")
            return nil
        }
    }
    
    func createRoom() async -> String? {
        do {
            let roomId = try await storage.createRoom(displayName: displayName)
            return roomId
        } catch {
            print("Couldn't create a room")
            return nil
        }
    }
    
    var joinCodePresent: Bool {
        !joinCode.isBlank
    }
    
    var displayNamePresent: Bool {
        !displayName.isBlank
    }
    
    var createRoomAllowed: Bool {
        displayNamePresent && !joinCodePresent
    }
    
    var joinRoomAllowed: Bool {
        displayNamePresent && joinCodePresent
    }
}
