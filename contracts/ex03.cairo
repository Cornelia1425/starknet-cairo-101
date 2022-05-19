######### Ex 03
# Using contract functions to manipulate contract variables
# 使用合约函数来操作合约变量
# In this exercice, you need to:
# 在这个练习中，你需要：
# - Use this contract's functions in order to manipulate an internal counter unique to your address
# - 使用此合约的函数来操作您地址独有的内部计数器
# - Once this counter reaches a certain value, call a specific function
# - 一旦这个计数器达到某个值，调用一个特定的函数
# - Your points are credited by the contract
# - 合约记入您的积分

## What you'll learn
## 您会学到：
# - How to declare mappings
# - 如何宣告映射
# - How to read and write to mappings
# - 如何读取和写入映射
# - How to use a function to manipulate storage variables
# - H如何使用函数来操作存储变量

######### General directives and imports
######### 內建函式库和输入
#
#


%lang starknet
%builtins pedersen range_check

from starkware.starknet.common.syscalls import (get_caller_address)
from starkware.cairo.common.cairo_builtins import HashBuiltin
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

# Declaring a mapping called user_counters_storage. For each 'account' key, which is a felt, we store a value which is a felt also.
# 宣告一个名为 user_counters_storage 的映射。 对于每个作为felt的“帐户”键，我们存储一个也是felt的值。
@storage_var
func user_counters_storage(account: felt) -> (user_counters_storage: felt):
end

#
# Declaring getters
# 宣告 getters
# Public variables should be declared explicitly with a getter
# 公共变量应明确地用 getter 宣告
#

# Declaring a getter for our mappings. It takes one argument as a parameter, the account you wish to read the counter of
# 为我们的映射宣告一个 getter。 它将一个argument作为参数，即您希望读取计数器的值的帐户
@view
func user_counters{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (user_counter: felt):
    let (user_counter) = user_counters_storage.read(account)
    return (user_counter)
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
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # Checking that user's counter is equal to 7
    # 检查用户的计数器的值是否等于 7
    let (current_counter_value) = user_counters_storage.read(sender_address)
    assert current_counter_value = 7

    # Checking if the user has validated the exercice before
    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # Sending points to the address specified as parameter
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

@external
func reset_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # Reinitializing the user counter
    # 重新初始化用户的计数器的值
    user_counters_storage.write(sender_address, 0)
    return()
end

@external
func increment_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # Reading counter from storage
    # 从存储中读取计数器的值
    let (current_counter_value) = user_counters_storage.read(sender_address)
    # Writing updated value to storage
    # 将更新的值写入存储
    user_counters_storage.write(sender_address, current_counter_value+2)
    return()
end

@external
func decrement_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # Reading counter from storage
    # 从存储中读取计数器的值
    let (current_counter_value) = user_counters_storage.read(sender_address)
    # Writing updated value to storage
    # 将更新的值写入存储
    user_counters_storage.write(sender_address, current_counter_value-1)
    return()
end





