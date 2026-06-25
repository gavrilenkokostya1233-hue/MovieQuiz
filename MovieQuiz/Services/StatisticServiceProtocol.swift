//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Konstantin on 23.06.2026.
//
protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct: Int, total amount: Int)
}
