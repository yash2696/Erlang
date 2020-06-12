-module(customers).
-export([custBar/6]).
    custBar(MoneyID, CustName, CustAmount, BankData, RandAmount, CustRecord) -> 
               {_, OldCustAmount} = CustRecord,
               if (length(BankData) == 0) or (CustAmount == 0)
                    ->
                        if length(BankData) == 0
                             ->
                                 MoneyID ! {finalCustRplBdataZr,{CustName, CustAmount, OldCustAmount}};
                            true ->
                                MoneyID ! {finalCustRplCusAmtZr,{CustName, CustAmount, OldCustAmount}}
                        end; 
                   true ->
                        {RandBankName, _} = lists:nth(rand:uniform(length(BankData)), BankData),
                        if CustAmount - RandAmount < 50
                             ->
                                   if CustAmount == RandAmount
                                        ->
                                                NewRandAmount = RandAmount;  
                                       true ->
                                            NewRandAmount = rand:uniform(CustAmount - RandAmount)    
                                   end;
                            true ->
                                    NewRandAmount = rand:uniform(50) 
                        end,
                        
                        RandBankName ! {self(), MoneyID, CustName, RandAmount},
                        receive
                                {replyBankPve, {CustName, RandAmount}} ->
                                    timer:sleep(100),
                                    MoneyID ! {replyCustPve, {RandBankName, CustName, RandAmount}},
                                    custBar(MoneyID, CustName, CustAmount - RandAmount, BankData, NewRandAmount, CustRecord);
                                {replyBankNve, {CustName, RandAmount}} ->
                                    timer:sleep(100),
                                    MoneyID ! {replyCustNve, {RandBankName, CustName, RandAmount}},
                                    NewBankData = proplists:delete(RandBankName, BankData),
                                    custBar(MoneyID, CustName, CustAmount, NewBankData, NewRandAmount, CustRecord)
                           end
               end.
               

    
