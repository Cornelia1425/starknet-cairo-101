######### Ex 10
## Composability
## Composability可组合性
# In this exercice, you need to:
# 在这个练习中，你需要：
# - Use this contract to retrieve the address of contract ex10b.cairo, which holds the key to this exercice
# - 使用此合约检索合约 ex10b.cairo 的地址，该合约持有此练习的密钥
# - Find the secret key in ex10b.cairo
# - 在 ex10b.cairo 中找到密钥
# - Call claim_points() in this exercice with the secret value
# - 在这个练习中使用秘密值呼叫 claim_points()函数
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

from contracts.utils.Iex10b import Iex10b

#
# Declaring storage vars
# 声明存储变量
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

@storage_var
func ex10b_address_storage() -> (ex10b_address_storage: felt):
end

#
# View functions
# 只读函数
#
@view
func ex10b_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (ex10b_address: felt):
    let (ex10b_address) = ex10b_address_storage.read()
    return (ex10b_address)
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
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(secret_value_i_guess: felt, next_secret_value_i_chose: felt):
    # Reading caller address
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()

    # Retrieve secret value by READING 
    # 通过 读取 拿到秘密值
    let (ex10b_address) = ex10b_address_storage.read()
    let (secret_value) = Iex10b.secret_value(contract_address=ex10b_address)
    assert secret_value = secret_value_i_guess

    # choosing next secret_value for contract 10b. We don't want 0, it's not funny
    # 为合约 10b 选择下一个 secret_value。 不要0！
    assert_not_zero(next_secret_value_i_chose)
    Iex10b.change_secret_value(contract_address=ex10b_address, new_secret_value= next_secret_value_i_chose)

    # Checking if the user has validated the exercice before
    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # Sending points to the address specified as parameter
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end


##
## Temporary functions, will remove once account contracts are live and usable with Nile
## 临时功能，一旦帐户合同生效并可与Nile使用，将被删除
##
##
@storage_var
func setup_is_finished() -> (setup_is_finished : felt):
end

@external
func set_ex_10b_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(ex10b_address: felt):
    let (permission) = setup_is_finished.read()
    assert permission = 0
    ex10b_address_storage.write(ex10b_address)
    setup_is_finished.write(1)
    return()
end
