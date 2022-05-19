######### Ex 08
## Recursions - basics
## 递归 - 基础
# In this exercice, you need to:
# 在这个练习中，你需要：
# - Use this contract's claim_points() function
# - 使用这个合约的 claim_points() 函数
# - Your points are credited by the contract
# - 由合约记入您的积分



%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import (assert_not_zero, assert_le)
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
# 声明存储变量
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

@storage_var
func user_values_storage(account: felt, slot: felt) -> (user_values_storage: felt):
end


#
# Declaring getters
# 声明 getters
# Public variables should be declared explicitly with a getter
# 公共变量应明确地用 getter 声明
#

@view
func user_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt, slot: felt) -> (value: felt):
    let (value) = user_values_storage.read(account, slot)
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
# Calling this function will simply credit 2 points to the address specified in parameter
# 呼叫此函数，指定地址将得2分
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()

    # Checking the value of user_values_storage for the user, at slot 10
    # 检查用户第10个slot的 user_values_storage 的值
    let (user_value_at_slot_ten) = user_values_storage.read(sender_address, 10)

    # This value should be equal to 10
    # 第10个slot的 user_values_storage 的值应该为 10
    assert user_value_at_slot_ten = 10

    # Checking if the user has validated the exercice before
    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # Sending points to the address specified as parameter
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

# This function takes an array as a parameter
# 该函数接收的参数为一个阵列
# In order to pass it, the user needs to pass both the array and its length
# 为了通过，用户需要传递阵列和它的长度
# This complexity is abstracted away by voyager, where you simply need to pass an array
# 操作被 voyager 简化了，你只需要在voyager中给它一个数组
@external
func set_user_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt, array_len: felt, array: felt*):

    set_user_values_internal(account, array_len, array)
    return ()
end

#
# Internal functions
# 内部函数
#
#

func set_user_values_internal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account:felt, length : felt, array : felt*):
    # This function is used recursively to set all the user values
    # 此函数用于递归地设置所有值
    # Recursively, we first go through the length of the array
    #递归，我们先遍历阵列的长度
    # Once at the end of the array (length = 0), we start to rearrange the array
    # 一旦在数组的末尾（长度 = 0），我们开始重新排列阵列
    if length == 0:
        # Start with the end of the array.
        # 从阵列末尾开始
        return ()
    end

    # If length is NOT zero, then the function calls itself again, moving forward one slot
    # 如果长度不为零，则函数通过向前移动一个slot，再次调用自身
    set_user_values_internal(account = account, length=length - 1, array=array + 1)

    # This part of the function is first reached when length=0.
    # 在length=0时，首次调用这部分函数
    user_values_storage.write(account, length - 1, [array])
    return ()
end


