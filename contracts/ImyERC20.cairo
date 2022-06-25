%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace ImyERC20:
    # Mint function
    func mint(to: felt, amount: Uint256) -> ():
    end
end
