//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Konstantin on 23.06.2026.
//
import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan (_ another: GameResult) -> Bool {
        correct > another.correct
    }
    
    
}
