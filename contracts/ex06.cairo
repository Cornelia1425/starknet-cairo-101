######### Ex 06
# External vs internal functions
# 外部与内部函数
# In this exercice, you need to:
# 在这个练习中，您需要：
# - Use a function to get assigned a private variable
# - 使用一个函数来分配一个私有变量
# - Use an internal function to duplicate this variable in a public variable
# - 使用内部函数在公共变量中复制此变量
# - Use a function to show you know the correct value of the private variable
# - 使用函数表示您知道私有变量的正确值
# - Your points are credited by the contract
# - 由合约记入您的积分


%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import (get_caller_address)

from contracts.utils.ex00_base import (
    tderc20_address,
    has_validated_exercise,
    distribute_points,
    validate_exercise,
    ex_initializer
)

#
# Declaring storage vars
# 宣告存储变量
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

@storage_var
func user_slots_storage(account: felt) -> (user_slots_storage: felt):
end

@storage_var
func user_values_public_storage(account: felt) -> (user_values_public_storage: felt):
end

@storage_var
func values_mapped_secret_storage(slot: felt) -> (values_mapped_secret_storage: felt):
end

@storage_var
func was_initialized() -> (was_initialized: felt):
end

@storage_var
func next_slot() -> (next_slot: felt):
end


#
# Declaring getters
# 宣告 getters
# Public variables should be declared explicitly with a getter
# 公共变量应明确地用 getter 宣告
#

@view
func user_slots{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (user_slot: felt):
    let (user_slot) = user_slots_storage.read(account)
    return (user_slot)
end

@view
func user_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (user_value: felt):
    let (value) = user_values_public_storage.read(account)
    return (value)
end


#
# Constructor
# 建构函数
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
    # Still sneaky.
    # 又皮一下！
    # Or not. Is this psyops?
    # 或者是心理战？；）
    let (value) = values_mapped_secret_storage.read(user_slot)
    assert value = expected_value

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
    let (next_value) = values_mapped_secret_storage.read(next_slot_temp + 1)
    if next_value == 0:
        user_slots_storage.write(sender_address, 1)
        next_slot.write(0)
    else:
        user_slots_storage.write(sender_address, next_slot_temp + 1)
        next_slot.write(next_slot_temp + 1)
    end
    return()
end

@external
func external_handler_for_internal_function{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(a_value: felt):
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # Just for fun
    # 皮一下
    assert a_value = 0
    # Calling internal function
    # 呼叫内部函数
    copy_secret_value_to_readable_mapping(sender_address)
    return()
end

#
# Internal functions
# 内部函数
# These functions can only be called by functions inside the same contract
# 这些函数只能被同一个合约内的函数调用
# Maybe some external functions allow you to call these?
# 也许一些外部函数允许你调用这些？
#

func copy_secret_value_to_readable_mapping{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(sender_address: felt):
    # Checking that the user got a slot assigned
    # 检查用户是否获得了分配的slot
    let (user_slot) = user_slots_storage.read(sender_address)
    assert_not_zero(user_slot)

    # Reading user secret value
    # 读取神秘值
    let (secret_value) = values_mapped_secret_storage.read(user_slot)

    # Copying the value from non accessible values_mapped_secret_storage to 
    # 将值从不可访问的 values_mapped_secret_storage 复制到可读公共存储中
    user_values_public_storage.write(sender_address, secret_value)
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
        # 以sum=0开始
        return ()
    end


    set_a_random_value(values_len=values_len - 1, values=values + 1 )
    values_mapped_secret_storage.write(values_len-1, [values])

    return ()
end



