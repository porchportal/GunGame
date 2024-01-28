//
//  ScoreManagement.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 22/1/2567 BE.
//

import Foundation

func updateHighScore(with score: Int) -> Void{
    var newScore = loadScore()
    newScore.append(score)
    newScore.sort()
    newScore.reverse()
    if newScore.count == 6{
        newScore.remove(at: newScore.count - 1)
    }
    UserDefaults.standard.set(newScore, forKey: "Drop game high scores")
}
func loadScore() -> [Int]{
    var scores : [Int] = [0]
    if let rawData = UserDefaults.standard.object(forKey: "Drop game high scores"){
        if let savedScore = rawData as? [Int]{
            scores = savedScore
        }
    }
    scores.sort()
    scores.reverse()
    return scores
}
