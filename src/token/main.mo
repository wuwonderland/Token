import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";

actor Token {


    Debug.print("Hello");

    let owner: Principal = Principal.fromText("twoyw-b4jet-y6q7r-ktmx7-uibb4-bohuc-bmygr-qod3w-7l2pv-kyr5b-hae");
    let totalSupply: Nat = 1000000000;
    let symbol: Text = "GENIUS COINS";

    private stable var balanceEntries: [(Principal, Nat)] = []; // Using this stable variable because this is serialized data type. It is very expensive in terms of time and internet computer that will be money and computation.
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

            if (balances.size() < 1) {
                balances.put(owner, totalSupply);
                };
    // balances.put(owner, totalSupply); //this move to postupgrade to keep track with totalSupply

    public query func balanceOf(who: Principal): async Nat {
        let currentBalance: Nat = switch (balances.get(who)) {
            case null 0;
            case (?result) result;
        };
        return currentBalance;
    };

    public query func getSymbol(): async Text {
        return symbol;
    };


    public shared(msg) func payOut(): async Text {
        Debug.print(debug_show(msg.caller));

        if (balances.get(msg.caller) == null) {
        let amount = 10000;
        // balances.put(msg.caller, amount); // need to call transfer function instead
        let result = await transfer(msg.caller, amount);
        return result;            
        } else {
            return "Already Claimed."
        }

    };


    public shared(msg) func transfer(to: Principal, amount: Nat): async Text {
        // let result = await payOut(); // TODO: this should be used as test to show Canister ID of actor
        let fromBalance = await balanceOf(msg.caller);
        if (fromBalance > amount) { 
            let newFromBalance : Nat = fromBalance - amount;
            balances.put(msg.caller, newFromBalance);

            let toBalance = await balanceOf(to);
            let newToBalance = toBalance + amount;
            balances.put(to, newToBalance);

            return "Success";
        } else {
            return "Insufficient funds to transfer."
        }
        
    };



        // if (balances.get(who) == null) {
        //     return 0;
        // } else {
        //     return balances.get(who);
        // }

        system func preupgrade() {
            balanceEntries := Iter.toArray(balances.entries()); // entries() is iterator over HashMap. 
        };

        system func postupgrade() {
            balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
            if (balances.size() < 1) {
                balances.put(owner, totalSupply);
            };
            
        };

};
