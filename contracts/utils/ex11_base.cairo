



######### Ex 00
## A contract from which other contracts can import functions
## 一个可被其他合约导入函数的合约

%lang starknet

from contracts.token.ITDERC20 import ITDERC20
from contracts.utils.Iplayers_registry import Iplayers_registry
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check
)
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import (get_contract_address)

#
# Declaring storage vars
# 宣告存储变量
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

@storage_var
func tderc20_address_storage() -> (tderc20_address_storage : felt):
end

@storage_var
func players_registry_storage() -> (tderc20_address_storage : felt):
end

@storage_var
func workshop_id_storage() -> (workshop_id_storage : felt):
end

@storage_var
func exercise_id_storage() -> (exercise_id_storage : felt):
end
#
@storage_var
func ex11_secret_value() -> (secret_value: felt):
end

#
# Declaring getters
# 宣告 getters
# Public variables should be declared explicitly with a getter
# 公共变量应明确地用 getter 宣告
#

@view
func tderc20_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_tderc20_address: felt):
    let (_tderc20_address) = tderc20_address_storage.read()
    return (_tderc20_address)
end

@view
func players_registry{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_players_registry: felt):
    let (_players_registry) = players_registry_storage.read()
    return (_players_registry)
end

@view
func workshop_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_workshop_id: felt):
    let (_workshop_id) = workshop_id_storage.read()
    return (_workshop_id)
end

@view
func exercise_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_exercise_id: felt):
    let (_exercise_id) = exercise_id_storage.read()
    return (_exercise_id)
end

@view
func has_validated_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (has_validated_exercice: felt):
    # reading player registry
    # 读取玩家的注册号registry
    let (_players_registry) = players_registry_storage.read()
    let (_workshop_id) = workshop_id_storage.read()
    let (_exercise_id) = exercise_id_storage.read()
    # Checking if the user already validated this exercice
    # 检查用户是否已经验证了这个练习
    let (has_current_user_validated_exercice) = Iplayers_registry.has_validated_exercice(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = _exercise_id)
    return (has_current_user_validated_exercice)
end

@view
func secret_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (secret_value: felt):
    let (secret_value) = ex11_secret_value.read()
    # There is a trick here
    # 这里小心！
    return (secret_value + 42069)
end


#
# Internal constructor
# 内部函数
# This function is used to initialize the contract. It can be called from the constructor
# 该函数用于初始化合约。 可以从构造函数中呼叫
#

func ex_initializer{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        _tderc20_address: felt,
        _players_registry: felt,
        _workshop_id: felt,
        _exercise_id: felt  
    ):
    tderc20_address_storage.write(_tderc20_address)
    players_registry_storage.write(_players_registry)
    workshop_id_storage.write(_workshop_id)
    exercise_id_storage.write(_exercise_id)
    ex11_secret_value.write(_tderc20_address)
    return ()
end

#
# Internal functions
# 内部函数
# These functions can not be called directly by a transaction
# 这些函数不能被交易直接调用
# Similar to internal functions in Solidity
# 类似于 Solidity 中的内部函数
#

func distribute_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(to: felt, amount: felt):
    
    # Converting felt to uint256. We assume it's a small number 
    # 将felt转换为 uint256。 我们假设这是一个较小的数字
	# We also add the required number of decimals
	# 我们还添加了所需的小数点位数
    let points_to_credit: Uint256 = Uint256(amount*1000000000000000000, 0)
    # Retrieving contract address from storage
    # 从存储中检索合约地址
    let (contract_address) = tderc20_address_storage.read()
    # Calling the ERC20 contract to distribute points
    # 调用ERC20合约分配积分
    ITDERC20.distribute_points(contract_address=contract_address, to = to, amount = points_to_credit)
    return()
end


func validate_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt):
    # reading player registry
    # 读取玩家注册号 registry
    let (_players_registry) = players_registry_storage.read()
    let (_workshop_id) = workshop_id_storage.read()
    let (_exercise_id) = exercise_id_storage.read()
    # Checking if the user already validated this exercice
    # 检查用户是否已经验证了这个练习
    let (has_current_user_validated_exercice) = Iplayers_registry.has_validated_exercice(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = _exercise_id)
    assert (has_current_user_validated_exercice) = 0

    # Marking the exercice as completed
    # 标记练习已完成
    Iplayers_registry.validate_exercice(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = _exercise_id)
    

    return()
end

func validate_answers{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(sender_address: felt, secret_value_i_guess: felt, next_secret_value_i_chose: felt):
    # CAREFUL THERE IS A TRAP FOR PEOPLE WHO WON'T READ THE CODE
    # 小心！对不阅读代码的人来说是一个陷阱
    # This exercice looks like the previous one, but actually the view secret_value returns a different value than secret_value
    # 这个练习看起来跟上个练习一样，但实际上view函数 secret_value 返回的值与 secret_value 不同
    # Sending the wrong execution result will remove some of your points, then validate the exercice. You won't be able to get those points back later on!
    # 错误的执行结果将导致减分。 您以后将无法获得这些积分！
    alloc_locals
    let (secret_value) = ex11_secret_value.read()
    local diff = secret_value_i_guess - secret_value 
    # Laying our trap here
    # 陷阱在这里
    if diff == 42069:
        # Converting felt to uint256. We assume it's a small number 
        # 将felt转换为 uint256。 我们假设这是一个较小的数字
	    # We also add the required number of decimals
	    # 我们还添加了所需的小数点位数
        let points_to_remove: Uint256 = Uint256(2*1000000000000000000, 0)
        # # Retrieving contract address from storage
        # # 从存储中检索合约地址
        let (contract_address) = tderc20_address_storage.read()
        # # Calling the ERC20 contract to distribute points
        # # 调用ERC20合约分配积分
        ITDERC20.remove_points(contract_address=contract_address, to = sender_address, amount = points_to_remove)
        # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...
        # 这里是必要的，因为已撤销references。 没事，就一会儿...
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        # If secret value is correct, set new secret value
        # 如果秘密值正确，则设置新的秘密值
        if diff == 0:
            assert_not_zero(next_secret_value_i_chose)
            ex11_secret_value.write(next_secret_value_i_chose)
            # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...
            # 这里是必要的，因为已撤销references。 没事，就一会儿...
            tempvar syscall_ptr = syscall_ptr
            tempvar pedersen_ptr = pedersen_ptr
            tempvar range_check_ptr = range_check_ptr
        # If secret value is incorrect, we revert
        # 如果秘密值不正确，我们会还原
        else:
            assert 1 = 0
            # This is necessary because of revoked references. Don't be scared, they won't stay around for too long...
            # # 这里是必要的，因为已撤销references。 没事，就一会儿...
            tempvar syscall_ptr = syscall_ptr
            tempvar pedersen_ptr = pedersen_ptr
            tempvar range_check_ptr = range_check_ptr
        end
    end

    return ()
end

