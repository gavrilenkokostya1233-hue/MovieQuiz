//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Konstantin on 19.06.2026.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() 
    func didFailToLoadData(with error: Error) 
}
