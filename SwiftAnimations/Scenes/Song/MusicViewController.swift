//
//  MusicViewController.swift
//  SwiftAnimations
//
//  Created by Irinka Datoshvili on 10.05.24.
//

import UIKit

class MusicViewController: UIViewController, MusicViewModelDelegate {
    
    // MARK: - Properties
    
    private let viewModel = MusicViewModel()
    
    private lazy var coverPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "cover")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var lastSelectedButton: UIButton?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Nunito-Regular", size: 24)
        label.text = "So Long, London"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Nunito-Regular", size: 18)
        label.text = "Taylor Swift"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var progressBar: UIProgressView = {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progressTintColor = UIColor(red: 58/255, green: 137/255, blue: 255/255, alpha: 1.0)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private lazy var tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 10/255, green: 9/255, blue: 30/255, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 40
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 50
        return view
    }()
    
    private lazy var homeButton: UIButton = {
        let button = makeTabBarButton(systemName: "house", size: CGSize(width: 21.44, height: 21.44))
        return button
    }()
    
    private lazy var musicButton: UIButton = {
        let button = makeTabBarButton(systemName: "music.note", size: CGSize(width: 21.44, height: 21.44))
        return button
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = makeTabBarButton(systemName: "heart", size: CGSize(width: 21.44, height: 21.44))
        return button
    }()
    
    private lazy var playPauseButton = makeButton(systemName: "play.circle.fill",  size: CGSize(width: 70, height: 70))
    private lazy var shuffleButton = makeButton(systemName: "shuffle", size: CGSize(width: 24, height: 24))
    private lazy var repeatButton = makeButton(systemName: "repeat", size: CGSize(width: 24, height: 24))
    private lazy var forwardButton = makeButton(systemName: "forward.end", size: CGSize(width: 24, height: 24))
    private lazy var backwardButton = makeButton(systemName: "backward.end", size: CGSize(width: 24, height: 24))
    
    private var verticalStackView: UIStackView!
    private var loader = UIImageView(image: UIImage(named: "Loader"))
    private var coverContainerView = UIView()
    lazy var labelsStackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 22/255, green: 20/255, blue: 17/255, alpha: 1.0)
        setupUI()
        viewModel.delegate = self
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        stylePlayButton()
        setupCoverPhotoContainer()
        setupLabels()
        setupProgressBar()
        setupButtonStackView()
        setupTabBarView()
        setupLoader()
        setupNavigationBarButtons()
        playPauseButton.addAction(UIAction { [weak self] _ in
            self?.playPauseButtonTapped()
        }, for: .touchUpInside)
    }
    
    // MARK: - Navigation Bar Buttons Setup
    
    private func setupNavigationBarButtons() {
        let buttons = [homeButton, musicButton, favoriteButton]
        for (index, button) in buttons.enumerated() {
            button.addAction(UIAction { [weak self] _ in
                self?.viewModel.selectButton(at: index)
                self?.updateNavigationBarButtons()
            }, for: .touchUpInside)
        }
        updateNavigationBarButtons()
    }
    
    // MARK: - Helper Methods
    
    private func makeTabBarButton(systemName: String, size: CGSize) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .white
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = size.width / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size.width),
            button.heightAnchor.constraint(equalToConstant: size.height)
        ])
        
        return button
    }
    
    private func setupTabBarView() {
        let stackView = UIStackView(arrangedSubviews: [homeButton, musicButton, favoriteButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.addSubview(stackView)
        view.addSubview(tabBarView)
        
        NSLayoutConstraint.activate([
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabBarView.heightAnchor.constraint(equalToConstant: 85),
            stackView.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor)
        ])
        
        [homeButton, musicButton, favoriteButton].forEach { button in
            button.addAction(UIAction { [weak self] _ in
                self?.handleTabBarButtonTapped(button)
            }, for: .touchUpInside)
        }
    }
    
    // MARK: - Button Animation
    
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            button.tintColor = UIColor(red: 58/255, green: 137/255, blue: 255/255, alpha: 1.0)
        }) { _ in
            
        }
    }
    
    // MARK: - Progress Bar Setup
    
    private func setupProgressBar() {
        view.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: labelsStackView.bottomAnchor, constant: 20),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
        ])
    }
    
    // MARK: - Cover Photo Container Setup
    
    private func setupCoverPhotoContainer() {
        coverContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coverContainerView)
        coverContainerView.addSubview(coverPhotoImageView)
        
        NSLayoutConstraint.activate([
            coverContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            coverContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            coverContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            coverPhotoImageView.topAnchor.constraint(equalTo: coverContainerView.topAnchor),
            coverPhotoImageView.leadingAnchor.constraint(equalTo: coverContainerView.leadingAnchor),
            coverPhotoImageView.trailingAnchor.constraint(equalTo: coverContainerView.trailingAnchor),
            coverPhotoImageView.bottomAnchor.constraint(equalTo: coverContainerView.bottomAnchor)
        ])
        coverPhotoImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        coverPhotoImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    // MARK: - Labels Setup
    
    private func setupLabels() {
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 10
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelsStackView)
        
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 368),
            labelsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Button Stack View Setup
    
    private func setupButtonStackView() {
        let buttons: [UIButton] = [shuffleButton, backwardButton, playPauseButton, forwardButton, repeatButton]
        let buttonStackView = createStackView(with: buttons, axis: .horizontal, spacing: 10)
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 40),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Stack View Helper
    
    private func createStackView(with views: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = axis
        stackView.alignment = .center
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Play Button Styling
    
    private func stylePlayButton() {
        playPauseButton.tintColor = UIColor(red: 58/255, green: 137/255, blue: 255/255, alpha: 1.0)
    }
    
    // MARK: - Button Creation Helper
    
    private func makeButton(systemName: String, size: CGSize) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size.width),
            button.heightAnchor.constraint(equalToConstant: size.height)
        ])
        return button
    }
    
    // MARK: - Loader Setup
    
    func setupLoader() {
        loader.contentMode = .scaleAspectFit
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.isHidden = true
        view.addSubview(loader)
        
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.widthAnchor.constraint(equalToConstant: 50),
            loader.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = .infinity
        loader.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    // MARK: - Play/Pause Button Action
    
    private func playPauseButtonTapped() {
        viewModel.togglePlayback()
        updateUI()
    }
    
    // MARK: - Update Navigation Bar Buttons
    
    private func updateNavigationBarButtons() {
        DispatchQueue.main.async {
            let buttons = [self.homeButton, self.musicButton, self.favoriteButton]
            for (_, button) in buttons.enumerated() {
                
                UIView.animate(withDuration: 0.1, animations: {
                    button.imageView?.transform = CGAffineTransform(scaleX: self.viewModel.updateNavigationBarButtonAppearance(), y: self.viewModel.updateNavigationBarButtonAppearance())
                }) { _ in
                    button.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Loader Setup if Needed
    
    private func setupLoaderIfNeeded() {
        if viewModel.isPlaying && viewModel.isShowingLoader {
            setupLoader()
            view.addSubview(loader)
            loader.isHidden = false
            
        } else {
            loader.removeFromSuperview()
        }
    }
    
    // MARK: - Update UI
    
    func updateUI() {
        DispatchQueue.main.async {
            self.playPauseButton.setImage(UIImage(systemName: self.viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill"), for: .normal)
            self.progressBar.setProgress(self.viewModel.progress, animated: true)
            
            self.setupLoaderIfNeeded()
            
            UIView.animate(withDuration: 0.5) {
                self.coverPhotoImageView.transform = self.viewModel.updateCoverPhotoSizeWithAnimation()
                
            }
        }
    }
    
    // MARK: - Handle Tab Bar Button Tap
    
    private func handleTabBarButtonTapped(_ tappedButton: UIButton) {
        tappedButton.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
        tappedButton.tintColor = UIColor(red: 58/255, green: 137/255, blue: 255/255, alpha: 1.0)
        
        if let lastButton = lastSelectedButton, lastButton != tappedButton {
            UIView.animate(withDuration: 0.1, animations: {
                lastButton.transform = .identity
                lastButton.tintColor = .white
            })
        }
        
        lastSelectedButton = tappedButton
    }
}
