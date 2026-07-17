import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Outlets (Элементы экрана)
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var counterLabel: UILabel! 
    @IBOutlet private var textLabel: UILabel!    
    @IBOutlet private var imageView: UIImageView! 
    
    // MARK: - Properties (Переменные контроллера)
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20

        showLoadingIndicator()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.viewController = self
        self.alertPresenter = alertPresenter
        
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        
    }
    
    // MARK: - QuestionFactoryDelegate 
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false 
        activityIndicator.startAnimating() 
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating() 
    }
    
    // MARK: - Actions 
    
    @IBAction private func YesButtonClicked(_ sender: Any) {
        presenter.YesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private Methods 
    
    func highlightImageBorder(isCorrectAnswer isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 10
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 18
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 18
        imageView.layer.borderWidth = 0
    }
    
    func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            
            self.showLoadingIndicator()
        }
        
        alertPresenter?.show(model: model)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in 
                self?.presenter.restartGame()
            }
            
        )
        
        alertPresenter?.show(model: model)
    }
    
}
