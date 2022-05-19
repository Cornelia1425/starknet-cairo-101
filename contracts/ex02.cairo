######### Ex 02
## Understanding asserts
## 理解 asserts
# In this exercice, you need to:
# 在本练习中，您需要：
# - Use this contract's claim_points() function
# - 使用此合约的 claim_points() 函数
# - Your points are credited by the contract
# - 您的积分由合约记入

## What you'll learn
## 您将学习
# - Using asserts
# - 使用 asserts
# - How to declare storage variables
# - 如何宣告存储变量
# - How to read storage variables
# - 如何读取存储变量
# - How to create getter functions
# - 如何创建getter函数
# Asserts are a basic building bloc allowing you to verify that two values are the same. 
# Asserts是一个基本的构建块，允许您验证两个值是否相同。
# They are similar to require() in Solidity
# 它们类似于 Solidity 中的 require()
# More information about basic storage https://www.cairo-by-example.com/basics/storage
# 有关基本存储的更多信息 https://www.cairo-by-example.com/basics/storage

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
# This variable is a felt and is called my_secret_value_storage
# 这个变量是一个felt，被称为 my_secret_value_storage
# From within a smart contract, it can be read with my_secret_value_storage.read() or written to with my_secret_value_storage.write()
# 在智能合约中，可以使用 my_secret_value_storage.read() 读取，或使用 my_secret_value_storage.write() 写入

@storage_var
func my_secret_value_storage() -> (my_secret_value_storage: felt):
end

#
# Declaring getters
# 宣告 getters
# Public variables should be declared explicitly with a getter
# 公共变量应明确地用 getter 宣告
#


@view
func my_secret_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (my_secret_value: felt):
    let (my_secret_value) = my_secret_value_storage.read()
    return (my_secret_value)
end

######### Constructor
######### 构造函数
# This function is called when the contract is deployed
# 部署合约时呼叫该函数
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _tderc20_address: felt,
        _players_registry: felt,
        _workshop_id: felt,
        _exercise_id: felt ,
        my_secret_value: felt
    ):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id)
    my_secret_value_storage.write(my_secret_value)
    return ()
end

######### External functions
######### 外部函数 
# These functions are callable by other contracts
# 这些函数可以被其他合约呼叫
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(my_value: felt):
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # Reading stored value from storage
    # 从存储中读取存储的值
    let (my_secret_value) = my_secret_value_storage.read()
    # Checking that the value sent is correct
    # 检查发送的值是否正确
    # Using assert this way is similar to using "require" in Solidity
    # assert 类似于在 Solidity 中使用“require”
    assert my_value = my_secret_value
    # Checking if the user has validated the exercice before
    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # Sending points to the address specified as parameter
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end







