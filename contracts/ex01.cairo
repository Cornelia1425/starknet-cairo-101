######### Ex 01

## Using a simple public contract function 
## 使用一个简单的公开合约函数

# In this exercice, you need to: 
# 在这个练习中，您需要：
# - Use this contract's claim_points() function 
# --使用本合约的claim_points()函数
# - Your points are credited by the contract 
# --由合约记入您的积分

## What you'll learn 
## 您会学到什么
# - General smart contract syntax 
# --通用智能合约的语法
# - Calling a function 
# --呼叫一个函数

######### General directives and imports 
######### 內建函式庫和输入
#
#

%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_caller_address)

from contracts.utils.ex00_base import (
    tderc20_address,
    has_validated_exercise,
    distribute_points,
    validate_exercise,
    ex_initializer
)


######### Constructor
######### 建构函数
# This function is called when the contract is deployed 
# 部署合约时呼叫该函数
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

######### External functions 
######### 外部函数 
# These functions are callable by other contracts 
# 这些函数可以被其他合约呼叫
#

# This function is called claim_points 
# 这个函数是得分函数claim_points
# It takes one argument as a parameter (sender_address), which is a felt. Read more about felts here https://www.cairo-lang.org/docs/hello_cairo/intro.html#field-element
# 它需要的输入是一个参数 (sender_address)，这是一个felt。在此处阅读有关felt的更多信息 https://www.cairo-lang.org/docs/hello_cairo/intro.html#field-element
# It also has implicit arguments (syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr). Read more about implicit arguments here https://www.cairo-lang.org/docs/how_cairo_works/builtins.html
# 它还包括隐含的参数（syscall_ptr：feel *、pedersen_ptr：HashBuiltin *、range_check_ptr）。在此处阅读有关隐含的参数的更多信息 https://www.cairo-lang.org/docs/how_cairo_works/builtins.html

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # Reading caller address
    # 读取呼叫者您的地址
    let (sender_address) = get_caller_address()
    # Checking if the user has validated the exercice before
    # 检查用户之前是否验证过练习

    validate_exercise(sender_address)
    # Sending points to the address specified as parameter
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end



