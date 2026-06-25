//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Konstantin on 20.06.2026.
//
import UIKit

class AlertPresenter {
    
    weak var viewController: MovieQuizViewController?
    
    func show(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title, 
            message: model.message, 
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in 
            model.completion()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
