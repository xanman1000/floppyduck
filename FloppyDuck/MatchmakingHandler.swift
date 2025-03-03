//
//  MatchmakingHandler.swift
//  FloppyDuck
//
//  Created for FloppyDuck game
//

import GameKit

protocol MatchmakingHandlerDelegate: AnyObject {
    func matchmakingHandler(_ handler: MatchmakingHandler, didFind match: GKMatch)
    func matchmakingHandler(_ handler: MatchmakingHandler, matchmakingFailed error: Error?)
    func matchmakingHandlerCanceled(_ handler: MatchmakingHandler)
}

class MatchmakingHandler: NSObject, GKMatchmakerViewControllerDelegate {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    weak var delegate: MatchmakingHandlerDelegate?
    var matchRequest: GKMatchRequest
    
    // MARK: - Initialization
    
    init(minPlayers: Int = 2, maxPlayers: Int = 2, viewController: UIViewController) {
        self.viewController = viewController
        self.matchRequest = GKMatchRequest()
        self.matchRequest.minPlayers = minPlayers
        self.matchRequest.maxPlayers = maxPlayers
        
        super.init()
    }
    
    // MARK: - Start Matchmaking
    
    func startMatchmaking() {
        guard let viewController = viewController else { return }
        
        if !GKLocalPlayer.local.isAuthenticated {
            let alert = UIAlertController(title: "Game Center Required", 
                                         message: "Please sign in to Game Center to use multiplayer features.", 
                                       preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
            return
        }
        
        let matchmakerViewController = GKMatchmakerViewController(matchRequest: matchRequest)
        matchmakerViewController?.matchmakerDelegate = self
        
        viewController.present(matchmakerViewController!, animated: true)
    }
    
    // MARK: - GKMatchmakerViewControllerDelegate Methods
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.matchmakingHandlerCanceled(self)
        }
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.matchmakingHandler(self, didFind: match)
        }
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.matchmakingHandler(self, matchmakingFailed: error)
        }
    }
} 