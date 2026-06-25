//
//  StaticService.swift
//  MovieQuiz
//
//  Created by Konstantin on 24.06.2026.
//

import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case bestGame
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQustionAsked
    }
    
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    private var totalQuestionAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQustionAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQustionAsked.rawValue)
        }
    }
}

extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGame.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(
                forKey: Keys.bestGameDate.rawValue
            ) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey:Keys.bestGame.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }

    var totalAccuracy: Double {
        get {
            if totalQuestionAsked == 0 {
                return 0.0
            }
            else {
                return Double(totalCorrectAnswers) / Double(totalQuestionAsked) * 100 
            }
        }
    }

    func store(correct: Int, total amount: Int) {
        totalCorrectAnswers += correct
        totalQuestionAsked += amount
        gamesCount += 1
        let currentGame = GameResult(
            correct: correct,
            total: amount,
            date: Date()
        )
        let best = currentGame.isBetterThan(bestGame)
        
        if best {
            bestGame = currentGame
        }
    }

    
}
