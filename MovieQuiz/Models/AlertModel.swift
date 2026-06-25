//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Konstantin on 20.06.2026.
//
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)
}
