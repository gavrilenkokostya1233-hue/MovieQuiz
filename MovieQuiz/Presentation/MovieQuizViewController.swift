import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Outlets (Элементы экрана)
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel! 
    @IBOutlet private weak var textLabel: UILabel!    
    @IBOutlet private weak var imageView: UIImageView! 
    
    // MARK: - Properties (Переменные контроллера)
    
    private let presenter = MovieQuizPresenter()
    private var statisticService: StatisticServiceProtocol? = StatisticService()
    private var questionFactory: QuestionFactoryProtocol? 
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?  
    private var correctAnswers = 0            
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        showLoadingIndicator()
        questionFactory?.loadData()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.viewController = self
        self.alertPresenter = alertPresenter
        
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        
    }
    
    // MARK: - QuestionFactoryDelegate 
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false 
        activityIndicator.startAnimating() 
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {

        guard let question = question else { return }
        
        currentQuestion = question
        
        let viewModel = presenter.convert(model: question)
        
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel) 
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true 
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions 
    
    @IBAction func YesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true 
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false 
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods 
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1 
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 10
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 18

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults() 
            self.imageView.layer.borderWidth = 0 
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 18
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        alertPresenter?.show(model: model)
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            statisticService
                .store(
                    correct: correctAnswers,
                    total: presenter.questionsAmount
                )
            let dateString = statisticService.bestGame.date.dateTimeString
            let text = "Ваш результат: \(correctAnswers) / \(presenter.questionsAmount) \nКоличество сыграных квизов: \(statisticService.gamesCount) \nРекорд: \(statisticService.bestGame.correct) / \(statisticService.bestGame.total) (\(dateString)) \nСредняя точность: \(statisticService.totalAccuracy) %"
            let viewModel = QuizResultsViewModel( 
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel) 
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in 
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
            
        )
        
        alertPresenter?.show(model: model)
    }
    
}
