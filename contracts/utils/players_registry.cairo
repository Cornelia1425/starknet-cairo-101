######### Players registry
######### 玩家注册
## A contract to record all addresses who participated, and which exercises and workshops they completed
## 此合约记录所有参与的地址，以及他们完成了哪些练习和workshop

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check
)
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import (get_caller_address)
#
# Declaring storage vars
# 声明存储变量
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

@storage_var
func has_validated_exercice_storage(account: felt, workshop: felt, exercise: felt) -> (has_validated_exercice_storage: felt):
end

@storage_var
func exercises_and_admins_accounts(account: felt) -> (permission: felt):
end

@storage_var
func next_player_rank_storage() -> (next_player_rank_storage: felt):
end

@storage_var
func players_registry_storage(rank: felt) -> (account: felt):
end

@storage_var
func players_ranks_storage(account: felt) -> (rank: felt):
end

#
# Declaring getters
# 声明 getters
# Public variables should be declared explicitly with a getter
# 公共变量应明确地用 getter 声明
#

@view
func has_validated_exercice{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt, workshop: felt, exercise: felt) -> (has_validated_exercice: felt):
    let (has_validated_exercice) = has_validated_exercice_storage.read(account, workshop, exercise)
    return (has_validated_exercice)
end

@view
func is_exercise_or_admin{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (permission: felt):
    let (permission: felt) = exercises_and_admins_accounts.read(account)
    return (permission)
end

@view
func next_player_rank{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (next_player_rank: felt):
    let (next_player_rank) = next_player_rank_storage.read()
    return (next_player_rank)
end

@view
func players_registry{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(rank: felt) -> (account: felt):
    let (account) = players_registry_storage.read(rank)
    return (account)
end

@view
func player_ranks{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (rank: felt):
    let (rank) = players_ranks_storage.read(account)
    return (rank)
end

#
# Events
# Events事件
# Keeping tracks of what happened
# 记录发生的事情
#
@event
func modificate_exercise_or_admin(account : felt, permission : felt):
end

@event
func new_player(account: felt, rank: felt):
end

@event
func new_validation(account: felt, workshop: felt, exercise: felt):
end

#
# Internal constructor
# 内部函数
# This function is used to initialize the contract. It can be called from the constructor
# 该函数用于初始化合约。 可以从构造函数中呼叫
#

@constructor
func constructor{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        first_admin: felt
    ):
    exercises_and_admins_accounts.write(first_admin, 1)
    modificate_exercise_or_admin.emit(account=first_admin, permission=1)
    next_player_rank_storage.write(1)
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

func only_exercise_or_admin{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    let (caller) = get_caller_address()
    let (permission) = exercises_and_admins_accounts.read(account=caller)
    assert permission = 1
    return ()
end

func _set_exercises_or_admins{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(accounts_len: felt, accounts: felt*):

    if accounts_len == 0:
        # Start with sum=0.
        # 以 sum=0 开始
        return ()
    end

    # If length is NOT zero, then the function calls itself again, by moving forward one slot
    # 如果长度不为零，则函数再次调用自身，向前移动一个slot
    _set_exercises_or_admins(accounts_len=accounts_len - 1, accounts=accounts + 1)

    # This part of the function is first reached when length=0.
    # 这部分函数在length=0时首先被执行
    exercises_and_admins_accounts.write([accounts], 1)
    modificate_exercise_or_admin.emit(account=[accounts], permission=1)

    return ()
end

#
# External functions
# 外部函数
#
#
#

@external
func set_exercise_or_admin{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(account: felt, permission: felt):
    only_exercise_or_admin()
    exercises_and_admins_accounts.write(account, permission)
    modificate_exercise_or_admin.emit(account=account, permission=permission)

    return ()
end

@external
func set_exercises_or_admins{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(accounts_len: felt, accounts: felt*):
    only_exercise_or_admin()
    _set_exercises_or_admins(accounts_len, accounts)
    return ()
end

@external
func validate_exercice{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt, workshop: felt, exercise: felt):	
	only_exercise_or_admin()
	# Checking if the user already validated this exercice
    # 检查用户是否已经验证了这个练习
	let (has_current_user_validated_exercice) = has_validated_exercice_storage.read(account, workshop, exercise)
	assert (has_current_user_validated_exercice) = 0

	# Marking the exercice as completed
    # 标记练习已完成
	has_validated_exercice_storage.write(account, workshop, exercise, 1)
    new_validation.emit(account=account, workshop=workshop, exercise=exercise)

    # Recording player if he is not yet recorded
    # 记录玩家，如果他还未被记录的话
    let (player_rank) = players_ranks_storage.read(account)
    
    if player_rank == 0:
        # Player is not yet record, let's record
        # 玩家还没有记录，让我们记录
        let (next_player_rank) = next_player_rank_storage.read()
        players_registry_storage.write(next_player_rank, account)
        players_ranks_storage.write(account, next_player_rank)
        let next_player_rank_plus_one = next_player_rank + 1
        next_player_rank_storage.write(next_player_rank_plus_one)
        new_player.emit(account=account, rank=next_player_rank)
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

	return()
end





