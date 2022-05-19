# StarkNet Cairo 101
**通过这个简单的教程来学习 Cairo — Starknet开发和使用的程式语言。
通过完成练习来获取代币，了解 StarkNet 智能合约的运作。**
​
## 介绍
### 免责声明
​
这篇教程将通过一系列小练习让您初步了解Starknet。Starknet是以太坊主网上第一个使用ZK-Rollup 解决方案（零知识证明）的第二层网络。（更多关于Starknet的内容：https://0xzx.com/2021082602321689060.html）
​
StarkNet 仍处于 Alpha 阶段，这意味着它仍在持续开发中。目前一些功能有修补的部分是非常正常的。
​
## 如何使用本篇教程
​
**简单来说就是：完成练习并获得代币。**
这一系列练习题是在测试网上的 StarkNet Alpha 上部署的一组智能合约。
每个智能合约都是一个练习题——每一题概述了 Cairo 智能合约语言的一个特性。
答对练习后，积分会以 ERC20 代币的形式记入您的Argent X账户中。 [ERC20 token](contracts/token/TDERC20.cairo).
​
这一系列练习题的重点是 *阅读* Cairo 代码和 StarkNet 智能合约，以了解其语法
您不需要在您的电脑上编码或安装任何东西来做题，在网页上完成即可。
​
入门—完成前两个练习—可能需要花多一点时间。坚持下去！一旦弄清楚一些基本概念，会变得更容易的。享受学习的过程！
​
该教程是一系列教程的第一部分，习题将涵盖广泛的智能合约概念（编写和部署 ERC20/ERC721、bridging assets,L1 <-> L2 消息传递……）。
另：如有兴趣帮助编写教程，请联系创作者Henri [Reach out](https://twitter.com/HenriLieutaud)!
​
### 提供反馈
完成习题后，您的反馈对我们很重要。
**请填写这个表格[this form](https://forms.reform.app/starkware/untitled-form-4/kaes2e) 让我们了解如何可以做得更好。** 
​
本教程旨在尽可能做到通俗易懂。如果您觉得在解题中有困难，也请告诉我们。
​
有问题请加入我们discord群组，注册并加入频道 [Discord server](https://discord.gg/B7PevJGCCw), register and join channel #tutorials-support
​
## 开始练习
​
### 创建您的账户合约
**为了完成教程，您需要获得积分。** 您需要部署一个合约，建立一个钱包。答对习题后，积分将打入您的钱包里。
-   目前最简单的设置方法是使用 Argent X，下载 chrome 扩展程序([download the chrome extension](https://chrome.google.com/webstore/detail/argent-x-starknet-wallet/dlcobpjiigpikoobohmabehhmhfoodbb/)  或查直接下载（ [check their repo](https://github.com/argentlabs/argent-x)).
-   按照说明安装扩展并部署账户合约
-   确保您在 Goerli 测试网网络上
-   本教程的积分保存在合约  `0x074002c7df47096f490a1a89b086b8a468f2e7c686e04a024d93b7c59f934f83`中。单击 Argent X 中的“添加代币”以显示您的积分余额。
-   将 Voyager 连接到您的帐户合约。这将允许您通过您的钱包进行您的交易。
​
### 使用Voyager
在本教程中，我们将通过 StarkNet 的区块浏览器 Voyager 与我们的合约进行交互 [Voyager](https://goerli.voyager.online/), StarkNet's block explorer. 

-> 将 Voyager 连接到您的帐户合同。这将允许您通过您的钱包进行您的交易。（voyager是可以浏览starknet区块的浏览器。关于voyager英文介绍看这里：  [Voyager介绍](https://medium.com/nethermind-eth/introducing-voyager-the-window-to-starknet-c948f3a07a9b)



在寻查看合约/交易时，请始终确保您使用的是测试版本 - Goerli 版本的 Voyager！
-   使用此链接访问交易： [https://goerli.voyager.online/tx/your-tx-hash](https://goerli.voyager.online/tx/your-tx-hash)
-   使用此链接访问合约： [https://goerli.voyager.online/contract/your-contract-address](https://goerli.voyager.online/contract/your-contract-address)
-   通过voyager中的“读/写合约”按键，访问合约的读/写功能
​
### 获得积分

​
​
**每个练习都是一个单独的智能合约。** 它包含的代码在正确执行时，会将每题2分的积分发送到您的Argent X地址。
​
由于目前无法通过您的账户合约轻松发送交易，因此，您必须每次在得分时指定您的地址。积分由函数 `distribute_points()` 分配。函数`validate_exercice`读出来是1，则记录您已经成功完成了该题（每题只能获得一次积分）。 

您的目标是：

![Graph](assets/diagram.png)
### 阅读代码 -> 遵循说明 -> 阅读代码中的注释 -> 呼叫函数
​
​
### 检查您的进度
​
#### 计算你的分数
​
您的积分将记入 Argent X；虽然可能需要一些时间。如果您想实时监控您的积分数，您还可以在 voyager 中查看您的余额：
​
-   前往 voyager 中的 ERC20 [ERC20 counter](https://goerli.voyager.online/contract/0x074002c7df47096f490a1a89b086b8a468f2e7c686e04a024d93b7c59f934f83#readContract) ，在“阅读合同”选项中 
-   在"balanceOf"函数中输入您的地址 
​
#### 交易状态
​
您发送了一笔交易，如果它在 voyager 中显示为“未检测到”，这可能意味着两件事：
​
-   您的交易处于待处理状态，很快就会被包含在一个区块中。等待几分钟后它将在 voyager 中显示。
-   你的交易是无效的，不会被包含在一个区块中（StarkNet 中没有失败的交易）。
​
您可以（且应该）使用以下链接： [https://alpha4.starknet.io/feeder_gateway/get_transaction_receipt?transactionHash=](https://alpha4.starknet.io/feeder_gateway/get_transaction_receipt?transactionHash=) 检查您的交易状态，您可以在其中附上您的交易哈希值（transaction hash）。

​
### 练习题和合约地址
### 合约地址
|Topic 题目|Contract code 合约代码|Contract on voyager 合约链接|
|---|---|---|
|Points counter 积分计数器ERC20|[Points counter ERC20](contracts/token/TDERC20.cairo)|[Link](https://goerli.voyager.online/contract/0x074002c7df47096f490a1a89b086b8a468f2e7c686e04a024d93b7c59f934f83)|
|General syntax 基本语法|[Ex01](contracts/ex01.cairo)|[Link](https://goerli.voyager.online/contract/0x04b9b3cea3d4b21f7f272a26cf0d54f40348a9d8509f951b217e33d4e9c80af2)|
|Storage variables, getters, asserts 存储变量，getters, 断言|[Ex02](contracts/ex02.cairo)|[Link](https://goerli.voyager.online/contract/0x06511a41c0620d756ff9e3c6b27d5aea2d9b65e162abdec72c4d746c0a1aca05)|
|Reading and writing storage variables 读写存储变量|[Ex03](contracts/ex03.cairo)|[Link](https://goerli.voyager.online/contract/0x044a68c9052a5208a46aee5d0af6f6a3e30686ab9ce3e852c4b817d0a76f2f09)|
|Mappings 映射|[Ex04](contracts/ex04.cairo)|[Link](https://goerli.voyager.online/contract/0x04e701814214c5d82215a134c31029986b0d05a2592c0c977fe2330263dc7304)|
|Variable visibility 变量可见度|[Ex05](contracts/ex05.cairo)|[Link](https://goerli.voyager.online/contract/0x01e7285636d7d147df6e2eacb044611e13ce79048c4ac21d0209c8c923108975)|
|Events 事件|[Ex12](contracts/ex12.cairo)|[Link](https://goerli.voyager.online/contract/0x0658e159d61d4428b6d5fa90aa20083786674c49a645fe416fc4c35b145f8a83)|
|Functions visibility 函数可见度|[Ex06](contracts/ex06.cairo)|[Link](https://goerli.voyager.online/contract/0x02abaa69541bd4630225cd69fa87d08a6e8fb80f4c7c2e8d3568fa59e71eec26)|
|Comparing values 比较值|[Ex07](contracts/ex07.cairo)|[Link](https://goerli.voyager.online/contract/0x07d9f4f818592b7a97f2c7e5915733ed022f96313cb61bde2c27a9fbd729a5a4)|
|Recursions level 1 递归 1|[Ex08](contracts/ex08.cairo)|[Link](https://goerli.voyager.online/contract/0x072d42eb599c9ec14d1f7209223226cb1436898c6930480c6a2f6998c6ceb9fe)|
|Recursions level 2 递归 2|[Ex09](contracts/ex09.cairo)|[Link](https://goerli.voyager.online/contract/0x035203b6c0b68ef87127a7d77f36de4279ceb79ea2d8099f854f51fc28074de4)|
|Composability 可组合性|[Ex10](contracts/ex10.cairo)|[Link](https://goerli.voyager.online/contract/0x071e59fbd7e724b94ad1f6d4bba1ff7161a834c6b19c4b88719ad640d5a6105c)|
|Importing functions 导入函数|[Ex11](contracts/ex11.cairo)|[Link](https://goerli.voyager.online/contract/0x06e124eba8dcf1ebe207d6adb366193511373801b49742b39ace5c868b795e68)|
|Privacy on StarkNet StarkNet上的隐私|[Ex13](contracts/ex13.cairo)|[Link](https://goerli.voyager.online/contract/0x07b271402ce18e1bcc1b64f555cdc23693b0eb091d71644f72b6c220814c1425)|

​
​
## 贡献
### 如果您想对这个项目有所贡献的话，非常欢迎！
- 如果您发现一些错误，请更正错误
- 如果您认为对题目需要更多的解释，请在练习的评论中添加解释
- 添加练习题，展示您最喜欢的cairo程式语言的特点
​
### 重启这个项目
- 在你的机器上复制这个repository
- 按照这些说明设置环境 [these instructions](https://starknet.io/docs/quickstart.html#quickstart)
- 安装cairo [Nile](https://github.com/OpenZeppelin/nile).
- 测试你是否能够编译这个项目
```
nile compile
```
