//
//  ContentView.swift
//  dice2
//
//  Created by 詠淨 on 2023/5/20.
//

import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    @State private var numOfDice: Int = 1  // 骰子數量的狀態變量
    @State private var prevNumOfDice: Int = 1  // 上一次的骰子數量，用於比較是否改變
    @State private var sum: Int = 0  // 骰子總和
    
    @State private var diceArray: [Int] = []  // 骰子數值的陣列
    @State private var positionArray: [CGRect] = []  // 骰子位置的陣列
    @State private var isRolling: Bool = false  // 是否正在擲骰子的狀態
    private let player = AVPlayer()  // AVPlayer 實例，用於播放音效
    
    var body: some View {
        VStack {
            Text("Sum: \(sum)")  // 顯示骰子總和的標籤
                .font(.headline)
                .padding()
            
            HStack {
                Stepper(value: $numOfDice, in: 1...6, step: 1) {
                    Text("Number of Dice: \(numOfDice)")  // 顯示骰子數量的標籤
                    ForEach(diceArray, id: \.self) { diceValue in
                        Image(systemName: "die.face.\(diceValue).fill")  // 顯示骰子圖像
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 65, height: 65)
                            .padding()
                            .rotationEffect(isRolling ? .degrees(360) : .zero)  // 如果正在擲骰子，則使骰子旋轉
                            .animation(.linear.repeatForever(), value: isRolling)  // 設定旋轉動畫效果
                    }
                }
                .padding()
                
                Button(action: {
                    rollDice()
                }) {
                    Text("Roll")  // 擲骰子按鈕
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            
            if !diceArray.isEmpty {
                HStack {
                    ForEach(diceArray, id: \.self) { diceValue in
                        Image(systemName: "die.face.\(diceValue).fill")  // 顯示擲出的骰子結果
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 65, height: 65)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .background(
            Image("woodBg")  // 背景圖像
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
        
        .onAppear {
            DiceRollSoundPlayer.shared.prepare()  // 準備播放音效
        }
    }
    
    private func rollDice() {
        prevNumOfDice = numOfDice
        sum = 0
        diceArray.removeAll()
        positionArray.removeAll()
        
        for _ in 1...numOfDice {
            let diceValue = Int.random(in: 1...6)  // 隨機生成骰子數值
            diceArray.append(diceValue)
            
            sum += diceValue  // 更新骰子總和
        }
        
        DiceRollSoundPlayer.shared.play()  // 播放擲骰子音效
    }
}

final class DiceRollSoundPlayer {
    static let shared = DiceRollSoundPlayer()  // 單例模式
    
    private var player: AVPlayer?
    
    private init() {}
    
    func prepare() {
        guard let fileUrl = Bundle.main.url(forResource: "rollDiceSound", withExtension: "mp3") else { return }  // 設定音效檔案路徑
        player = AVPlayer(url: fileUrl)  // 創建 AVPlayer 實例
        player?.volume = 0.9  // 設定音量
    }
    
    func play() {
        player?.seek(to: CMTime.zero)  // 將播放時間設定為音效開始位置
        player?.play()  // 播放音效
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
