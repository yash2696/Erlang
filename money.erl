-module(money). 
-export([start/0, func/1, func1/2, custFoo/5, print_Msg/1, func2/1, unregisterBank/1, final_msgs/0]). 

start() -> 
	{ok, CustData} = file:consult("customers.txt"),
	{ok, BankData} = file:consult("banks.txt"),
	io:fwrite("** Customers and loan objectives **\n"),
	func(CustData),
	io:fwrite("\n"),
	io:fwrite("** Banks and financial resources **\n"),
	func(BankData),
	io:fwrite("\n"),
	lists:foreach(fun func2/1, BankData),
	func1(CustData, BankData),
	print_Msg(BankData).

func([]) -> [];
func([H|T]) ->
	{Key, Val} = H,
	io:fwrite("~p: ~p~n", [Key, Val]),
    func(T).

custFoo(Key, Val, RandBankName, RandBankAmount, RandAmount) -> 

	PID = spawn(customers, custBar, []),
	PID ! {self(), Key, Val, RandBankName, RandBankAmount, RandAmount}.
            

func1([], _) -> [];
func1([H|T], BankData) ->
	{Key, Val} = H,
	if Val < 50
		 ->
				RandAmount = rand:uniform(Val);
		true ->
				RandAmount = rand:uniform(50)
	end,
	spawn(customers, custBar, [self(), Key, Val, BankData, RandAmount, H]),
	func1(T, BankData).
	
print_Msg(BankData) ->
		receive
                {replyCustPve,{BankName, CustName, RandAmount}} ->
					io:fwrite("~p approves a loan of ~p dollors from ~p~n", [BankName, RandAmount, CustName]),
					print_Msg(BankData);
				{replyCustNve,{BankName, CustName, RandAmount}} ->
					io:fwrite("~p denies a loan of ~p dollors from ~p~n", [BankName, RandAmount, CustName]),
					print_Msg(BankData);
				{replyBankPve, {CustName, RandBankName, RandAmount}} ->
					io:fwrite("~p requests a loan of ~p dollar(s) from ~p~n", [CustName, RandAmount, RandBankName]),
					print_Msg(BankData);
				{finalBankRplBdataBlnc, {BankName, BankAmount}} ->
					io:fwrite("~p has ~p dollar(s) remaining ~n", [BankName, BankAmount]),
					print_Msg(BankData)
				after 6000 ->
						final_msgs()
						%unregisterBank(BankData),
					%io:fwrite("end")
			end.
			
func2(H) ->
	{BankName, BankAmount} = H,
	Pid = spawn(bank, bnk, [self(), BankName, BankAmount]),
	%io:fwrite("~p ~p\n", [Pid, BankName]),
	register(BankName, Pid).

unregisterBank([]) -> [];
unregisterBank([H|T]) ->
	{BankName, _} = H,
	unregister(BankName),
	unregisterBank(T).

final_msgs() ->
		receive
				{finalCustRplBdataZr,{CustName, CustAmount, OldCustAmount}} ->
						io:fwrite("~p was only able to borrow ~p dollar(s). Boo Hoo!\n", [CustName, OldCustAmount - CustAmount]),
						final_msgs();
					{finalCustRplCusAmtZr,{CustName, CustAmount, OldCustAmount}} ->
						io:fwrite("~p has reached the objective of ~p dollar(s). Woo Hoo!\n", [CustName, OldCustAmount - CustAmount]),
						final_msgs()
		after 1500 ->
			io:fwrite("** END **")
		end.

