######### Ex 09
## Recursions - advanced
## 递归 - 高级
# In this exercice, you need to:
# 在这个练习中，您需要：
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
# View functions
# 唯读函数
#
@view
func get_sum{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(array_len: felt, array: felt*) -> (array_sum: felt):
    let (array_sum) = get_sum_internal(array_len, array)
    return (array_sum)
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
# Calling this function will simply credit 2 points to the address specified in parameter
# 呼叫此函数，指定地址将得2分
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(array_len: felt, array: felt*):
    # Checking that the array is at least of length 4
    # 检查阵列的长度是否至少为 4
    assert_le(4, array_len)

    # Calculating the sum of the array sent by the user
    # 计算用户提供的阵列的总和
    let (array_sum) = get_sum_internal(array_len, array)

    # The sum should be higher than 50
    # 总和应高于 50
    assert_le ( 50, array_sum)
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # Checking if the user has validated the exercice before
    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # Sending points to the address specified as parameter
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

#
# Internal functions
# 内部函数
#
#

func get_sum_internal{ range_check_ptr}(length : felt, array : felt*) -> (sum : felt):
    # This function is used recursively to calculate the sum of all the values in an array
    # 该函数用于递归计算阵列中所有值的总和
    # Recursively, we first go through the length of the array
    # 递归，我们先遍历阵列
    # Once at the end of the array (length = 0), we start summing
    # 一旦在数组的末尾（长度 = 0），我们开始求和
    if length == 0:
        # Start with sum=0.
        # 以 sum=0 开始
        return (sum=0)
    end

    # If length is NOT zero, then the function calls itself again, by moving forward one slot
    # 如果长度不为零，则函数通过向前移动一个slot，再次调用自身
    let (current_sum) = get_sum_internal(length=length - 1, array=array + 1)

    # This part of the function is first reached when length=0.
    # 在length=0时，首次调用这部分函数
    # Checking that the first value in the array ([array]) is not 0
    # 检查阵列 ([array]) 中的第一个值是否不为 0
    assert_not_zero([array])
    # The sum begins
    # 开始求和
    let sum = [array] + current_sum

    assert_le(current_sum * 2, sum)
    # The return function targets the body of this function
    # 返回函数的目标是这个函数的主体
    return (sum)
end


