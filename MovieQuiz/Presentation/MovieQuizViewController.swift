import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets (Элементы экрана)
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel! 
    @IBOutlet private weak var textLabel: UILabel!    
    @IBOutlet private weak var imageView: UIImageView! 
    
    // MARK: - Properties (Переменные контроллера)
    private let questionsAmount: Int = 10 
    
    private var statisticService: StatisticServiceProtocol? = StatisticService()
    private var questionFactory: QuestionFactoryProtocol? 
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?  
    private var currentQuestionIndex = 0     
    private var correctAnswers = 0            
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let factory = QuestionFactory()
        
        factory.delegate = self
        
        self.questionFactory = factory
        
        questionFactory?.requestNextQuestion()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.viewController = self
        self.alertPresenter = alertPresenter
        
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        
    }
    
    // MARK: - QuestionFactoryDelegate (Ловим ответы от Фабрики)
    
    func didReceiveNextQuestion(question: QuizQuestion?) {

        guard let question = question else { return }
        
        currentQuestion = question
        
        let viewModel = convert(model: question)
        
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel) 
        }
    }
    
    // MARK: - Actions (Нажатия на кнопки)
    
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
    
    // MARK: - Private Methods (Внутренняя логика экрана)
    
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel( 
            image: UIImage(named: model.image) ?? UIImage(), 
            question: model.text, 
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        ) 
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 18
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let dateString = statisticService.bestGame.date.dateTimeString
            let text = "Ваш результат: \(correctAnswers) / \(questionsAmount) \nКоличество сыграных квизов: \(statisticService.gamesCount) \nРекорд: \(statisticService.bestGame.correct) / \(statisticService.bestGame.total) (\(dateString)) \nСредняя точность: \(statisticService.totalAccuracy) %"
            let viewModel = QuizResultsViewModel( 
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel) 
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in 
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
            
        )
        
        alertPresenter?.show(model: model)
    }
    
}
