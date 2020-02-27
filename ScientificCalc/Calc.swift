//
//  Calc.swift
//
//  Created by USER on 2019/11/19.
//  Copyright © 2019 Akidon. All rights reserved.
//

/*
----- only_formulas ⇨ 数式 -----
 only_formulas = "12+3*456"
 ↓
 formulasList = ["12","+","3","*","456"]
 
----- 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation) -----
 1 + 2 ⇨ 1 2 +
 ( 1 + 2 ) * 3 ⇨ 1 2 + 3 *
 1 * ( 2 + 3 ) ⇨ 1 2 3 + *
 
 formulasList = ["12","+","3","*","456"]
 ↓
 buffa = ["12","3","456","*","+"]
 
 ----- 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え -----
 buffa = ["12","3","456","*","+"]
 ↓
 stack[0] = 1380 ←(計算結果)
*/

import Foundation

class Calc {
    //式を画面に（Fotmulas.text）に計算式として表示
    var only_formulas:String = ""
    
    //計算式を１つずつ配列に追加
    var formulasList:[String] = []
    
    //逆ポーランドへ変換する際に一時的に四則記号を保持する。最終的には空のリストとなる
    var stacks:[String] = []  //追加する時値はIndex[0]に追加、取り出す時もIndex[0]から取り出す
    
    //逆ポーランドへ変換した式を保持
    var buffa:[String] = []
    
    //for文の値を保持
    var num:String = ""
    
    //formulasへ追加する前に数字を組み合わせるための変数
    var combination:String = ""
    
    //答えの文字列を操作する変数
    var ans:String = ""
    
    //only_formulasの最後の文字を.countと見比べて判定するため
    var onlyFormulas_count = 0
    
    //一時的に使用する変数、様々な場所で短期間だけ記憶、使用する
    var oneTime_TF = false
    var oneTime_count = 0
    
    
    /*
    numが数値かどうかを判断する*引用元　https://teratail.com/questions/54252
    */
    func isOnlyNumber(_ str:String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES '\\\\d+'")
        return predicate.evaluate(with: str)
    }
    
    /*
    only_formulas ⇨　数式　に変換
    */
    func Only_formulasToFormula(){
        for i in only_formulas{  // only_formulas = "12+3*456"
            num = String(i)
            onlyFormulas_count += 1
            
            if oneTime_TF == true{  //*10^Xの時に通る
                oneTime_count += 1
                if oneTime_count >= 4{  // *からXまでの "1","0","^" の３つは必要ないため "^" 以降から処理
                    if only_formulas.count == onlyFormulas_count{
                        combination += num
                        //com_int += Int(combination)!
                        oneTime_count = 1
                        for _ in 0..<Int(combination)!{  //10 ** comInt の累乗計算を行う powは使えなかった
                            oneTime_count *= 10
                        }
                        formulasList.append(String(oneTime_count))
                        
                        //値の初期化
                        oneTime_TF = false
                        combination = ""
                        oneTime_count = 0
                    }else{
                        if isOnlyNumber(num){
                            combination += num
                        }else{
                            oneTime_count = 1
                            for i in 0..<Int(combination)!{
                                print("i -> " + String(i))
                                oneTime_count *= 10
                            }
                            
                            formulasList.append(String(oneTime_count))
                            formulasList.append(num)
                            oneTime_TF = false
                            combination = ""
                            oneTime_count = 0
                        }
                    }
                }
            }else{
                if num == "*"{
                    oneTime_TF = false
                    formulasList.append(combination)
                    formulasList.append("×")
                    combination = ""
                }else if isOnlyNumber(num) || num == "."{
                    combination += num
                }else if num == ")" || num == "+" || num == "-" || num == "×" || num == "÷"{
                    if formulasList.last != ")"{// ( 1 + 2 ) の時　) ここでは２だけを追加　最後に　)　を追加
                        formulasList.append(combination)
                        combination = ""
                    }
                    formulasList.append(num)
                    
                }else if num == "("{
                    formulasList.append(num)
                    
                }else{
                    print("Only_formulasToFormula ⇨ ERROR")
                }
            }
        }
        if combination != ""{ //1 + 2　で　num = ２　の時通る
            formulasList.append(combination)
        }
    }

    /*
    数式 ⇒ 逆ポーランド記法(Reverse Polish Notation) に変換
    */
    func Formula_To_Polish(){
        combination = ""
        for i in 0 ..< formulasList.count{ //formulasList = ["1","+","2","*","34"]
            num = formulasList[i]
            if isOnlyNumber(num) {  //numが数値かどうかを判断する。小数点が含まれる場合は検出されない
                buffa.append(num)
                
            }else if num.contains("."){  //小数点を含む場合を検出
                buffa.append(num)
                
            }else if num == ")"{  //( 1 + 2 )　で　num = ")"のとき stack = ["+","("]
                for _ in 0 ..< stacks.firstIndex(of: "(")!{  //firstIndex探索のため二重括弧以上も対応
                    buffa.append(stacks[0])
                    stacks.removeFirst()
                    }
                
            }else if num == "("{
                stacks.insert("(", at:0)  //stacksのIndex[0] に追加
                
            }else{ //演算記号はここを通る
                while true{  //stacksが空になるまでループする
                    if stacks.isEmpty{  //stacksが空になったらbreak
                        stacks.insert(num, at: 0)
                        break
                        
                    }else if num == "+" || num == "-"{  //stacksの一番上にある記号をbuffaに追加する。
                         //例 -> 1 + 2 - 3 で　num = "-" の時 buffa.append("+")
                        if stacks[0] == "(" {
                            stacks.insert(num, at: 0)
                            break
                        }else{  //numよりstacks[0]にある記号の方が優先順位が高い × > +
                            buffa.append(stacks[0])
                            stacks.removeFirst()
                        }
                        
                    }else if num == "×"{
                        if stacks[0] == "÷"{
                            buffa.append(stacks[0])
                            stacks.removeFirst()
                        }else{  //stacks[0] == "×" or "+" or "-" の時　ここを通る
                            stacks.insert(num, at: 0)
                            break
                        }
                        
                    }else if num == "÷"{  //優先順位　一番高い
                        stacks.insert(num, at: 0)
                        break
                        
                    }else{
                        print("Formula_To_Polish ⇨ EROOR")
                    }
                    stacks.insert(num, at: 0)
                    break
                    //ループ区間
                }
            }
        }
        //最後の演算記号がstacksに残るので、それをbuffaへ
        for i in 0 ..< stacks.count{
            if stacks[i] != "(" {
                buffa.append(stacks[i])
            }
        }
        stacks.removeAll()
    }
    
    
    /*
     逆ポーランド記法(Reverse Polish Notation) ⇒ 答え へ変換
     */
    func Polish_To_Answer() -> String{
        for i in 0 ..< buffa.count{ //buffaには逆ポーランドに変換された式が入っている
            /*
             1 + 2 で　buffa = ["2","1","+"]　、 buffa[i] = "+"　の時、stacks = ["2","1"]である
             num = 1 + 2
             removeよりstack = [] 空になり
             insertで　stacks = [3]となる。
             */
            if buffa[i] == "+" || buffa[i] == "-" || buffa[i] == "×" || buffa[i] == "÷"{
                switch buffa[i]{
                case "+":
                    num = String(Double(stacks[1])! + Double(stacks[0])!)
                case "-":
                    num = String(Double(stacks[1])! - Double(stacks[0])!)
                case "×":
                    num = String(Double(stacks[1])! * Double(stacks[0])!)
                case "÷":
                    num = String(Double(stacks[1])! / Double(stacks[0])!)
                default:
                    break
                }
                stacks.remove(at:1) //計算で使用した値を消去
                stacks.remove(at:0)
                stacks.insert(num, at: 0)//計算後の値を追加
            }else{ //数値はここを通る
                stacks.insert(buffa[i], at: 0)
            }
        }
        ans = stacks[0]
        
        if ans.suffix(2) == ".0"{  //ans = 5.0 などの時は、ans = 5 にする
            ans = String(ans.prefix(ans.count - 2))
        }
        return ans //答えを画面に表示
    }

    
    func ButtonZero() -> String {  //"0"の時、最初に0が来ないように改良する必要あり。
        only_formulas += "0" //計算式を表示するだけ
        return only_formulas
    }
    
    func Button(arg:String) -> String{  // "1" = tag 1 , "2" = tag 2 , ....., "9" = tag 9
    only_formulas += arg
    return only_formulas
    }
    
    func Signal(arg:String) -> String {  // "+" = tag 100 , "-" = tag 101 , "*" = tag 102 , "/" = tag 103
         switch arg{
         case "100":
             only_formulas += "+"
         case "101":
             only_formulas += "-"
         case "102":
             only_formulas += "×"
         case "103":
             only_formulas += "÷"
         default:
             print("Signal -> ERROR")
         }
        return only_formulas
     }
    
    func Parentheses(arg:String) -> String{ // "(" = tag 104 , ")" = tag 105
        switch arg{
            case "104":
                only_formulas += "("
            case "105":
                only_formulas += ")"
            default:
                print("Parenthese -> ERROR")
        }
        return only_formulas
    }
    
    func Equal() -> String{  // =
        Only_formulasToFormula()  // only_formulas ⇨ 数式
        Formula_To_Polish()       // 数式 ⇨ 逆ポーランド
        return Polish_To_Answer() // 逆ポーランド ⇨ 答え
    }
    
    func Delete() -> String{  //Del
        only_formulas.removeLast()
        return only_formulas
    }
    
    func AllClear() {  //AC
        formulasList.removeAll()
        stacks.removeAll()
        buffa.removeAll()
        num = ""
        combination = ""
        only_formulas = ""
        oneTime_TF = false
        oneTime_count = 0
        onlyFormulas_count = 0
    }
    
    func AnsBefore() -> String{  //前回のAnsを式に追加
        if ans == ""{
            return only_formulas
        }else{
            only_formulas.append(ans)
            return only_formulas
        }
    }
    
    func Point() -> String{  //小数点
        only_formulas.append(".")
        return only_formulas
    }
    
    func Multiplier() -> String{  //*10^X
        only_formulas.append("*10^")
        return only_formulas
    }
}
