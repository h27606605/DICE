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
    @State private var sum:Int = 0  // 骰子總和
    
    @State private var diceArray: [Int] = []  // 骰子數值的陣列
    @State private var positionArray: [CGRect] = []  // 骰子位置的陣列
    @State private var isRolling: Bool = false  // 是否正在擲骰子的狀態
    @State private var showBattle: Bool = false  // 是否顯示battle視窗
    private let player = AVPlayer()  // AVPlayer 實例，用於播放音效
    var body: some View {
        NavigationView {
            VStack {
                Menu {
                    Button("battle", role: .none) {
                        showBattle = true  // 點擊Menu時顯示battle選項
                    }
                } label: {
                    Label("Menu", systemImage: "list.bullet")
                }
                .menuStyle(BorderlessButtonMenuStyle()) // 設置選單樣式
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // 將視圖框架設置為左上角對齊
                Text(getOutput())
                    .font(.system(size: 60))
                    .padding()
                
                
                HStack {
                    Stepper(value: $numOfDice, in: 1...6, step: 1) {
                        Text("Number of Dice: \(numOfDice)")  // 顯示骰子數量的標籤
                        ForEach(diceArray.sorted(), id: \.self) { diceValue in
                            Image(systemName: "die.face.\(diceValue).fill")  // 顯示骰子圖像
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 65, height: 65)
                                .padding()
                            
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
            .navigationBarHidden(true)  // 隐藏導航欄
        }
        .fullScreenCover(isPresented: $showBattle) {
            BattleView()  // 顯示battle視窗
        }
        .onAppear {
            DiceRollSoundPlayer.shared.prepare()  // 準備播放音效
        }
        
    }
    
    private func getOutput() -> String {
        if diceArray.count == 4 {
            let sortedDice = diceArray.sorted()
            
            if sortedDice[0] == sortedDice[3]  {
                // 四顆骰子相同
                return "豹子"
            } else if sortedDice[1]  == sortedDice[3] || sortedDice[0] == sortedDice[2]{
                // 三顆骰子相同
                return "BG"
            } else if sortedDice[0] == sortedDice[1] {
                let sum = sortedDice[2] + sortedDice[3]
                return "\(sum)點"
            } else if sortedDice[1] == sortedDice[2] {
                let sum = sortedDice[0] + sortedDice[3]
                return "\(sum)點"
            } else if sortedDice[2] == sortedDice[3] {
                let sum = sortedDice[0] + sortedDice[1]
                return "\(sum)點"
            } else {
                // 其他情況為 BG
                return "BG"
            }
        } else {
            let sum = diceArray.reduce(0, +)
                    return "Sum: \(sum)"
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



struct BattleView: View {
    @State private var playerDice = 1
    @State private var computerDice = 1
    @State private var result = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("玩家")
                    .font(.headline)
                    .padding(.top)
                    .foregroundColor(.red)
                
                Image(systemName: "die.face.\(playerDice).fill")
                    .font(.system(size: 100))
                    .foregroundColor(.red)
                
                Text("電腦")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Image(systemName: "die.face.\(computerDice).fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                Text(result)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundColor(.yellow)
                
                Button(action: rollDice) {
                    Text("Roll Dice")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()  // 返回到前一個畫面
                }) {
                    Text("Back")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height) // 填滿整個螢幕
            .background(
                Image("woodBg")  // 背景圖像
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
    
    


    
    func rollDice() {
        playerDice = Int.random(in: 1...6)
        computerDice = Int.random(in: 1...6)
        
        if playerDice > computerDice {
            result = "玩家 wins!"
        } else if playerDice < computerDice {
            result = "電腦 wins!"
        } else {
            result = "平手!"
        }
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

