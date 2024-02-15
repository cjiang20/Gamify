//
//  ContentView.swift
//  ToDoList Game
//
//  Created by Christopher Jiang on 8/2/23.
//

import SwiftUI

struct ContentView: View {
    // Structs
    struct item: Identifiable {
        let name: String
        let price: Int
        let id: String
        var on: Bool
        let oneTime: Bool
        
        init(name: String, price: Int, id: String? = nil, on: String? = nil, oneTime: String? = nil) {
            self.name = name
            self.price = price
            self.id = id ?? String((0..<15).map{ _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()!})
            self.on = Bool(on ?? "false") ?? false
            self.oneTime = Bool(oneTime ?? "false") ?? false
        }
    }
    struct pair {
        var name: String
        var price: String
    }
    struct categories {
        var toDo: pair
        var oneTime: pair
        var reward: pair
        var rewardOneTime: pair
        var multiplier: pair
    }
    struct ItemCheckbox: View {
        @Binding var item: item
        var body: some View {
            HStack {
                Image(systemName: item.on ? "checkmark.square": "square")
            }
        }
    }

    
    // Mutables
    @FocusState var focus: Bool
    @State var swaps = ["tasks": true, "toDo": true, "reward": true]
    @State var points = ["dailyPoints": UserDefaults.standard.object(forKey: "dailyPoints") as? Int ?? 0, "totalPoints": UserDefaults.standard.object(forKey: "totalPoints") as? Int ?? 0, "oneTimePoints": UserDefaults.standard.object(forKey: "oneTimePoints") as? Int ?? 0]
    @State var fields = categories(toDo: pair(name: "", price: ""), oneTime: pair(name: "", price: ""), reward: pair(name: "", price: ""), rewardOneTime: pair(name: "", price: ""), multiplier: pair(name: "", price: ""))
    @State var toDoList : [item] = []
    @State var oneTimeList : [item] = []
    @State var rewardList : [item] = []
    @State var oneTimeRewardList : [item] = []
    @State var multiplierList : [item] = []
    
    // View
    var body: some View {
        VStack {
            ZStack {
                if swaps["tasks"] == true {
                    if swaps["toDo"] == true {
                        Text("Daily Points: \(points["dailyPoints"]!)")
                    }
                    else {
                        Text("One Time Points: \(points["oneTimePoints"]!)")
                    }
                }
                else {
                    Text("Total Points: \(points["totalPoints"]!)")
                }
            }
            Button("?", action: instruction)
            ZStack {
                if swaps["tasks"] == true {
                    ZStack {
                        if swaps["toDo"] == true {
                            VStack {
                                Button("To Do List", action: toDoSwap)
                                List {
                                    ForEach(toDoList) { list in
                                        HStack{
                                            Text("\(list.name)")
                                            Text("\(list.price)")
                                            Button("delete", action: {() in self.delete(currList: &toDoList, id : list.id, forKey: "toDoList")}).buttonStyle(BorderlessButtonStyle())
                                            Button("cash", action: {() in self.cash(currList: &toDoList, id : list.id, price : list.price, forKey: "toDoList", oneTime: Bool(list.oneTime) )}).buttonStyle(BorderlessButtonStyle())
                                        }
                                    }.onMove { from, to in
                                        toDoList.move(fromOffsets: from, toOffset: to)
                                    }
                                    HStack {
                                        TextField("Task", text: $fields.toDo.name).focused($focus)
                                        TextField("Payment", text: $fields.toDo.price).keyboardType(.numberPad).focused($focus)
                                        Button("add item", action: {() in self.addToList(currList: &toDoList, key: &fields.toDo, forKey: "toDoList")})
                                    }
                                }
                            }
                        }
                        else {
                            VStack {
                                Button("One Time List", action: toDoSwap)
                                List {
                                    ForEach(oneTimeList) { list in
                                        HStack{
                                            Text("\(list.name)")
                                            Text("\(list.price)")
                                            Button("delete", action: {() in self.delete(currList: &oneTimeList, id : list.id, forKey: "oneTimeList")}).buttonStyle(BorderlessButtonStyle())
                                            Button("move", action: {() in self.move(currList: &oneTimeList, id : list.id, name: list.name, price : list.price, forKey: "oneTimeRewardList")}).buttonStyle(BorderlessButtonStyle())
                                        }
                                    }.onMove { from, to in
                                        oneTimeList.move(fromOffsets: from, toOffset: to)
                                    }
                                    HStack {
                                        TextField("Task", text: $fields.oneTime.name).focused($focus)
                                        TextField("Payment", text: $fields.oneTime.price).keyboardType(.numberPad).focused($focus)
                                        Button("add item", action: {() in self.addToList(currList: &oneTimeList, key: &fields.oneTime, forKey: "oneTimeList")})
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    ZStack {
                        if swaps["reward"] == true {
                            VStack {
                                Button("Reward List", action: rewardSwap)
                                List {
                                    ForEach(rewardList) { list in
                                        HStack{
                                            Text("\(list.name)")
                                            Text("\(list.price)")
                                            Button("delete", action: {() in self.delete(currList: &rewardList, id : list.id, forKey: "rewardList")}).buttonStyle(BorderlessButtonStyle())
                                            Button("buy", action: {() in self.buy(currList: &rewardList, id : list.id, price : list.price, recur : true, forKey: "rewardList")}).buttonStyle(BorderlessButtonStyle())
                                        }
                                    }.onMove { from, to in
                                        rewardList.move(fromOffsets: from, toOffset: to)
                                    }
                                    HStack {
                                        TextField("Reward", text: $fields.reward.name).focused($focus)
                                        TextField("Price", text: $fields.reward.price).keyboardType(.numberPad).focused($focus)
                                        Button("add item", action: {() in self.addToList(currList: &rewardList, key: &fields.reward, forKey: "rewardList")})
                                    }
                                }
                            }
                        }
                        else {
                            VStack {
                                Button("One Time Reward List", action: rewardSwap)
                                List {
                                    ForEach(oneTimeRewardList) { list in
                                        HStack{
                                            Text("\(list.name)")
                                            Text("\(list.price)")
                                            Button("delete", action: {() in self.delete(currList: &oneTimeRewardList, id : list.id, forKey: "oneTimeRewardList")}).buttonStyle(BorderlessButtonStyle())
                                            Button("buy", action: {() in self.buy(currList: &oneTimeRewardList, id : list.id, price : list.price, recur: false, forKey: "oneTimeRewardList")}).buttonStyle(BorderlessButtonStyle())
                                        }
                                    }.onMove { from, to in
                                        oneTimeRewardList.move(fromOffsets: from, toOffset: to)
                                    }
                                    HStack {
                                        TextField("Reward", text: $fields.rewardOneTime.name).focused($focus)
                                        TextField("Price", text: $fields.rewardOneTime.price).keyboardType(.numberPad).focused($focus)
                                        Button("add item", action: {() in self.addToList(currList: &oneTimeRewardList, key: &fields.rewardOneTime, forKey: "oneTimeRewardList", oneTime: "true")})
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            if (swaps["tasks"] ?? true) {
                VStack {
                    Text("Multipliers")
                    List {
                        ForEach($multiplierList) { $list in
                            HStack{
                                Text("\(list.name)")
                                Text("\(list.price)x")
                                Button("delete", action: {() in self.delete(currList: &multiplierList, id : list.id, forKey: "multiplierList")}).buttonStyle(BorderlessButtonStyle())
                                ItemCheckbox(item: $list).onTapGesture {
                                    self.checkBox(currItem: &list)
                                    self.updateList(currList: multiplierList, forKey: "multiplierList")
                                }
                            }
                        }.onMove { from, to in
                            multiplierList.move(fromOffsets: from, toOffset: to)
                        }
                        HStack {
                            TextField("Name", text: $fields.multiplier.name).focused($focus)
                            TextField("Multiplier", text: $fields.multiplier.price).keyboardType(.numberPad).focused($focus)
                            Button("add item", action: {() in self.addToList(currList: &multiplierList, key: &fields.multiplier, forKey: "multiplierList")})
                        }
                    }
                }
            }
            ZStack {
                if swaps["tasks"] ?? true {
                    Button("Tasks", action: taskSwap)
                }
                else {
                    Button("Rewards", action: taskSwap)
                }
            }
        }.onAppear(perform: startGame)
    }
    
    // Functions
    func checkBox (currItem : inout item) {
        currItem.on.toggle()
    }
    func updateList (currList: [item], forKey: String) {
        UserDefaults.standard.set(encode(currList: currList), forKey: forKey)
    }
    func taskSwap () {
        swaps["tasks"]!.toggle()
    }
    func toDoSwap () {
        swaps["toDo"]!.toggle()
    }
    func rewardSwap () {
        swaps["reward"]!.toggle()
    }
    func instruction () {
        print("instructions")
    }
    func delete (currList : inout [item], id : String, forKey: String) {
        currList = currList.filter({$0.id != id})
        updateList(currList: currList, forKey: forKey)
    }
    func cash (currList : inout [item], id : String, price : Int, forKey: String, oneTime: Bool) {
        currList = currList.filter({$0.id != id})
        updateList(currList: currList, forKey: forKey)
        if !oneTime {
            let dailyPoints = price + points["dailyPoints"]!
            points["dailyPoints"] = dailyPoints
            UserDefaults.standard.set(dailyPoints, forKey: "dailyPoints")
        }
        else {
            let oneTimePoints = price + points["oneTimePoints"]!
            points["oneTimePoints"] = oneTimePoints
            UserDefaults.standard.set(oneTimePoints, forKey: "oneTimePoints")
        }
        
    }
    func move (currList : inout [item], id : String, name: String, price: Int, forKey: String) {
        currList = currList.filter({$0.id != id})
        updateList(currList: currList, forKey: forKey)
        fields.toDo = pair(name: name, price: String(price))
        addToList(currList: &toDoList, key: &fields.toDo, forKey: "toDoList", oneTime: "true")
    }
    func buy (currList : inout [item], id : String, price : Int, recur : Bool, forKey: String) {
        if price <= points["totalPoints"]! {
            let totalPoints = points["totalPoints"]! - price
            points["totalPoints"] = totalPoints
            UserDefaults.standard.set(totalPoints, forKey: "totalPoints")
            if !recur {
                currList = currList.filter({$0.id != id})
                updateList(currList: currList, forKey: forKey)
            }
        }
        else {
            print("not enough points")
        }
    }
    func addToList(currList : inout [item], key : inout pair, forKey: String, oneTime: String = "false") {
        focus = false
        let name = key.name
        let price = Int(key.price) ?? -1
        if name != "" && price >= 0 {
            currList.append(item(name: name, price: price, oneTime: oneTime))
            updateList(currList: currList, forKey: forKey)
            key.name = ""
            key.price = ""
        }
        else {
            print("error")
        }
    }
    func encode(currList : [item]) -> [[String: String]] {
        return currList.map {["name": $0.name, "price": String($0.price), "id": $0.id, "on": String($0.on)]}
    }
    func decode(currList : [[String: String]]) -> [item] {
        return currList.map {item(name: $0["name"] ?? "", price: Int($0["price"] ?? "0")! , id: $0["id"] ?? nil, on: $0["on"] ?? nil)}
    }
    func calcTotal() {
        var pointsEarned = points["dailyPoints"]!
        multiplierList = multiplierList.map {
            if $0.on {
                pointsEarned *= $0.price
            }
            return item(name: $0.name, price: $0.price, id: $0.id)
        }
        points["totalPoints"] = points["totalPoints"]! + pointsEarned + (points["oneTimePoints"] ?? 0)
        points["dailyPoints"] = 0
        points["oneTimePoints"] = 0
        UserDefaults.standard.set(points["totalPoints"], forKey:"totalPoints")
        UserDefaults.standard.set(points["dailyPoints"], forKey:"dailyPoints")
        updateList(currList: multiplierList, forKey: "multiplierList")
    }
    
    func startGame() {
        toDoList = decode(currList: UserDefaults.standard.object(forKey: "toDoList") as? [[String: String]] ?? [])
        oneTimeList = decode(currList: UserDefaults.standard.object(forKey: "oneTimeList") as? [[String: String]] ?? [])
        rewardList = decode(currList: UserDefaults.standard.object(forKey: "rewardList") as? [[String: String]] ?? [])
        oneTimeRewardList = decode(currList: UserDefaults.standard.object(forKey: "oneTimeRewardList") as? [[String: String]] ?? [])
        multiplierList = decode(currList: UserDefaults.standard.object(forKey: "multiplierList") as? [[String: String]] ?? [])
        let syncTime = Calendar.current.date(bySettingHour: 4, minute: 0, second: 0, of: Date())!
        let oldTime = UserDefaults.standard.object(forKey: "time") as? Date ?? syncTime
        if Date.now > oldTime {
            UserDefaults.standard.set(Calendar.current.date(byAdding: .day, value: 1, to: syncTime)!,forKey: "time")
            self.calcTotal()
        }
    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
