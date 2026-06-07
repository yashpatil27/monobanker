//
//  ParticipantDragPayload.swift
//  MonoBanker
//
//  Transferable wrapper around `Participant` so cards can participate in
//  the SwiftUI drag-and-drop system.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

extension UTType {
    static let monoBankerParticipant = UTType(exportedAs: "com.monobanker.participant")
}

struct ParticipantDragPayload: Codable, Transferable, Hashable {
    let participant: Participant

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .monoBankerParticipant)
    }
}
