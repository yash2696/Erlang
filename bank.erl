-module(bank).
-export([bnk/3]).
bnk(MoneyIDFromMny, BankName, BankAmount) -> 
                    receive
                            {CustID, MoneyID, CustName, RandAmount} ->
                                NewBankAmount = BankAmount - RandAmount,
                                timer:sleep(100),
                                if BankAmount >= RandAmount
                                     ->
                                            CustID ! {replyBankPve, {CustName, RandAmount}},
                                            MoneyID ! {replyBankPve, {CustName, BankName, RandAmount}},  
                                            bnk(MoneyID, BankName, NewBankAmount);
                                    true ->
                                            MoneyID ! {replyBankPve, {CustName, BankName, RandAmount}},
                                            CustID ! {replyBankNve, {CustName, RandAmount}},
                                            bnk(MoneyID, BankName, BankAmount)  
                                end

                            after 5000 ->
                                    MoneyIDFromMny ! {finalBankRplBdataBlnc, {BankName, BankAmount}}
                        end.
    