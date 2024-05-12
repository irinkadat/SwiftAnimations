//
//  MusicViewModel.swift
//  SwiftAnimations
//
//  Created by Irinka Datoshvili on 10.05.24.
//

import Foundation

// MARK: - Music View Model Delegate Protocol

protocol MusicViewModelDelegate: AnyObject {
    func updateUI()
    func setupLoader()
}

// MARK: - Music View Model Class

class MusicViewModel {
    
    // MARK: - Properties
    
    weak var delegate: MusicViewModelDelegate?
    var isPlaying: Bool = false
    var progress: Float = 0.0
    var timer: Timer?
    var isShowingLoader: Bool = false
    var selectedButtonIndex: Int? = nil
    
    // MARK: - Playback Methods
    
    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startTimer()
            isShowingLoader = true
            delegate?.updateUI()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updateCoverPhotoSizeWithAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isShowingLoader = false
                    self.delegate?.updateUI()
                    self.updateCoverPhotoSizeWithAnimation()
                }
            }
        } else {
            stopTimer()
            isShowingLoader = false
            delegate?.updateUI()
        }
    }
    
    // MARK: - Timer Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += 0.01
            if self.progress >= 1.0 {
                self.stopTimer()
                self.isPlaying = false
                self.progress = 0.0
                self.delegate?.updateUI()
            }
            self.delegate?.updateUI()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Cover Photo Methods
    
    func coverPhotoSize() -> CGAffineTransform {
        if isPlaying && !isShowingLoader {
            return CGAffineTransform(scaleX: 1, y: 1)
        } else {
            return CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
    }
    
    // MARK: - Button Selection Methods
    
    func selectButton(at index: Int) {
        if selectedButtonIndex == index {
            selectedButtonIndex = nil
        } else {
            selectedButtonIndex = index
        }
        delegate?.updateUI()
    }
    
    func shouldEnlargeButton(at index: Int) -> Bool {
        return selectedButtonIndex == index
    }
    
    // MARK: - Animation Methods
    
    @discardableResult
    func updateCoverPhotoSizeWithAnimation() -> CGAffineTransform {
        var targetTransform: CGAffineTransform
        if isShowingLoader || !isPlaying {
            targetTransform = coverPhotoSize()
            return targetTransform
        } else {
            targetTransform = .identity
            return targetTransform
        }
    }
    
    // MARK: - Navigation Bar Button Appearance Methods
    
    func updateNavigationBarButtonAppearance() -> CGFloat {
        var targetScale: CGFloat
        
        guard let index = selectedButtonIndex else {
            return 1
        }
        let shouldEnlarge = shouldEnlargeButton(at: index)
        targetScale = shouldEnlarge ? 1.2 : 1.0
        return targetScale
    }
}
