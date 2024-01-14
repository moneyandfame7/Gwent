//
//  GameEventManager.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 09.01.2024.
//

import Foundation

enum EventType {
    case gameStart

    case roundStart
    case roundEnd

    case turnStart
    case turnEnd
}

struct EventCb: Identifiable {
    let id = UUID()

    /// Якщо повертає true, одразу видаляємо
    let handler: () async -> Bool?
}

final class GameEventManager {
    private var callbacks: [EventType: [EventCb]] = [:]

    init() {
        print("GameEventManager init")
    }

    deinit {
        print("GameEventManager deinit")
    }

    func attach(for event: EventType, handler: @escaping () async -> Bool?) {
        let eventCb = EventCb(handler: handler)

        callbacks[event, default: []].append(eventCb)
    }

    func detach(for event: EventType, id: EventCb.ID) {
        callbacks[event, default: []].removeAll { $0.id == id }
    }

    func trigger(for event: EventType) async {
        guard let callbacks = callbacks[event] else {
            return
        }
        print("Trigger \(event) event.")

        for cb in callbacks {
            if let shouldRemove = await cb.handler(), shouldRemove {
                detach(for: event, id: cb.id)
            }
        }
    }

    func reset() {
        callbacks.removeAll()
    }
}
