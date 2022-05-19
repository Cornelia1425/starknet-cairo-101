######### Ex 04
# Reading a mapping
# 读取映射
# In this exercise, you need to:
# 在这个练习中，你需要：
# - Use a function to read a variable
# - U使用函数读取变量
# - Use a function to read a value in a mapping, where the slot you read is the value from the first call
# - 使用函数读取映射中的值，其中您读取的slot是第一次调用的值
# - Use a function to show you know the correct value of the value in the mapping
# - 使用函数显示你知道映射中值的正确值
# - Your points are credited by the contract
# - 由合约记入您的积分



%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address)
from starkware.cairo.common.math import assert_not_zero
from contracts.utils.ex00_base import (
    tderc20_address,
    has_validated_exercise,
    distribute_points,
    validate_exercise,
    ex_initializer
)


#
# Declaring storage vars
# 声明存储变量
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

@storage_var
func user_slots_storage(account: felt) -> (user_slots_storage: felt):
end

@storage_var
func values_mapped_storage(slot: felt) -> (values_mapped_storage: felt):
end

@storage_var
func was_initialized() -> (was_initialized: felt):
end

@storage_var
func next_slot() -> (next_slot: felt):
end


#
# Declaring getters
# 声明 getters
# Public variables should be declared explicitly with a getter
# 公共变量应明确地用 getter 声明
#

@view
func user_slots{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (user_slot: felt):
    let (user_slot) = user_slots_storage.read(account)
    return (user_slot)
end

@view
func values_mapped{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(slot: felt) -> (value: felt):
    let (value) = values_mapped_storage.read(slot)
    return (value)
end

#
# Constructor
# 构造函数
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _tderc20_address: felt,
        _players_registry: felt,
        _workshop_id: felt,
        _exercise_id: felt  
    ):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id)
    return ()
end

#
# External functions
# 外部函数
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(expected_value: felt):
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # Checking that the user got a slot assigned
    # 检查用户是否获得了分配的slot
    let (user_slot) = user_slots_storage.read(sender_address)
    assert_not_zero(user_slot)

    # Checking that the value provided by the user is the one we expect
    # 检查用户提供的值是否是我们期望的值
    # Yes, I'm sneaky
    # 皮一下！
    let (value) = values_mapped_storage.read(user_slot)
    assert value = expected_value + 32

    # Checking if the user has validated the exercice before
    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # Sending points to the address specified as parameter
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

@external
func assign_user_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    let (next_slot_temp) = next_slot.read()
    let (next_value) = values_mapped_storage.read(next_slot_temp + 1)
    if next_value == 0:
        user_slots_storage.write(sender_address, 1)
        next_slot.write(0)
    else:
        user_slots_storage.write(sender_address, next_slot_temp + 1)
        next_slot.write(next_slot_temp + 1)
    end
    return()
end

#
# External functions - Administration
# 外部函数 - 管理
# Only admins can call these. You don't need to understand them to finish the exercice.
# 只有管理员可以呼叫这些函数。 您无需了解它们即可完成练习。
#

@external
func set_random_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(values_len: felt, values: felt*):

    # Check if the random values were already initialized
    # 检查随机值是否已经初始化
    let (was_initialized_read) = was_initialized.read()
    assert was_initialized_read = 0
	
    # Storing passed values in the store
    # 在存储中存储通过的值
    set_a_random_value(values_len, values)

    # Mark that value store was initialized
    # 标记值存储已初始化
    was_initialized.write(1)
    return()
end

func set_a_random_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(values_len: felt, values: felt*):
    if values_len == 0:
        # Start with sum=0.
        # 以 sum=0 开始
        return ()
    end


    set_a_random_value(values_len=values_len - 1, values=values + 1 )
    values_mapped_storage.write(values_len-1, [values])

    return ()
end


