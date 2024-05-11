//
//  MusicViewModel.swift
//  SwiftAnimations
//
//  Created by Irinka Datoshvili on 10.05.24.
//

import Foundation

protocol MusicViewModelDelegate: AnyObject {
    func updateUI()
    func updateCoverPhotoSizeWithAnimation()
}

class MusicViewModel {
    weak var delegate: MusicViewModelDelegate?
    var isPlaying: Bool = false
    var progress: Float = 0.0
    var timer: Timer?
    var isShowingLoader: Bool = false
    var selectedButtonIndex: Int? = nil

    
    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startTimer()
            isShowingLoader = true
            delegate?.updateUI()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.updateCoverPhotoSizeWithAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isShowingLoader = false
                    self.delegate?.updateUI()
                    self.delegate?.updateCoverPhotoSizeWithAnimation()
                }
            }
        } else {
            stopTimer()
            isShowingLoader = false
            delegate?.updateUI()
        }
    }
    
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
    
    func coverPhotoSize() -> CGSize {
        if isPlaying && !isShowingLoader {
            return CGSize(width: 304, height: 319)
        } else if isShowingLoader {
            return CGSize(width: 215, height: 215)
        } else {
            return CGSize(width: 215, height: 215)
        }
    }
    
    func shouldUpdateCoverPhotoSize() -> Bool {
            return isShowingLoader || !isPlaying
        }
    
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
}


