%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IDTK:
    # Faucet function
    func faucet() -> (success: felt):
    end
    func transferFrom(sender: felt, recipient: felt, amount: Uint256) -> (success: felt):
    end
    func approve(spender: felt, amount: Uint256) -> (success: felt):
    end
    func increaseAllowance(spender: felt, added_value: Uint256) -> (success: felt):
    end
    func decreaseAllowance(spender: felt, subtracted_value: Uint256) -> (success: felt):
    end
    func allowance(owner: felt, spender: felt) -> (remaining: Uint256):
    end
end
