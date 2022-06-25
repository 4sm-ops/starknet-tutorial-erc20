# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

from contracts.IDTK import IDTK

from openzeppelin.security.safemath import SafeUint256

from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc20.library import ERC20

# Define a storage variable.
@storage_var
func balance() -> (res : felt):
end

# Keeps list of token holders 

@storage_var
func token_holders_list(account : felt) -> (amount : Uint256):
end


# Returns the current balance.
@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = balance.read()
    return (res)
end

# Returns the current custody balance.
@view
func tokens_in_custody{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account : felt) -> (amount : Uint256):
    let (res : Uint256) = token_holders_list.read(account)
    return (amount = res)
end

# returns ExerciseSolutionToken address
# latest ERC20 token address - 0x0522b348c36d563b11cc57f17aacd100393e1b639ff002cb4d4471c2ff5e7b2f 

@view
func deposit_tracker_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (deposit_tracker_token_address : felt):
    let address = 0x0522b348c36d563b11cc57f17aacd100393e1b639ff002cb4d4471c2ff5e7b2f
    return (deposit_tracker_token_address = address)
end


# Increases the balance by the given amount.
@external
func increase_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt):
    let (res) = balance.read()
    balance.write(res + amount)
    return ()
end



# get tokens from Dummy ERC20 contract
@external
func get_tokens_from_contract{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (amount : Uint256):

    let (caller_address) = get_caller_address()

    let (faucet_call_result) = IDTK.faucet(0x029260ce936efafa6d0042bc59757a653e3f992b97960c1c4f8ccd63b7a90136)

    let (res : Uint256) = token_holders_list.read(caller_address)

    let (new_amount: Uint256) = SafeUint256.add(res, Uint256(100*1000000000000000000, 0))

    # Register as breeder
    token_holders_list.write(account=caller_address, value=new_amount)

    return (amount = Uint256(100*1000000000000000000, 0))
end


# withdraw tokens of specific user
@external
func withdraw_all_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (amount : Uint256):

    let (caller_address) = get_caller_address()
    let (custody_address) = get_contract_address()

    let (withdraw_amount : Uint256) = token_holders_list.read(caller_address)

    let (res) = IDTK.approve(0x029260ce936efafa6d0042bc59757a653e3f992b97960c1c4f8ccd63b7a90136, custody_address, withdraw_amount)

    let (transfer_result) = IDTK.transferFrom(0x029260ce936efafa6d0042bc59757a653e3f992b97960c1c4f8ccd63b7a90136, custody_address, caller_address, withdraw_amount)

    # Register as breeder
    token_holders_list.write(account=caller_address, value=Uint256(0, 0))

    return (amount = withdraw_amount)
end

#allow spent amount
@external 
func allow_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : Uint256) -> ():

    let (custody_address) = get_contract_address()

    let (res) = IDTK.approve(0x029260ce936efafa6d0042bc59757a653e3f992b97960c1c4f8ccd63b7a90136, custody_address, amount)
    return()
end


#increase spent amount
@external 
func increase_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : Uint256) -> ():

    let (custody_address) = get_contract_address()

    let (inc_res) = IDTK.increaseAllowance(0x029260ce936efafa6d0042bc59757a653e3f992b97960c1c4f8ccd63b7a90136, custody_address, amount)
    return()
end

#decresase spent amount
@external 
func decrease_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : Uint256) -> ():
    let (custody_address) = get_contract_address()

    let (inc_res) = IDTK.decreaseAllowance(0x029260ce936efafa6d0042bc59757a653e3f992b97960c1c4f8ccd63b7a90136, custody_address, amount)
    return()
end



# deposit tokens of Dummy ERC20 contract
@external
func deposit_tokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : Uint256) -> (total_amount : Uint256):

    let (caller_address) = get_caller_address()

    # Charge deposited amount
    let dummy_token_address = 0x029260ce936efafa6d0042bc59757a653e3f992b97960c1c4f8ccd63b7a90136
    let (contract_address) = get_contract_address()

    IDTK.transferFrom(
        contract_address=dummy_token_address,
        sender=caller_address,
        recipient=contract_address,
        amount=amount
    )

    let (old_amount : Uint256) = token_holders_list.read(caller_address)

    let (new_amount: Uint256) = SafeUint256.add(old_amount, amount)

    # Register as breeder
    token_holders_list.write(account=caller_address, value=new_amount)

    return (total_amount = new_amount)
end



