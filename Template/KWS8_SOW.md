
---
title: "Memory Compiler Statement of Work"

toc-title: "Contents"
---

::: {.section-break}
:::

## 版本修订记录

| 版本 | 描述 | 更新人员 | 日期 |
| --- | ------------------- | --- | --- |
| V01 | 初版, 发布Memory Compiler工作任务，发布Memory Compiler测试片规格 | 佘一奇 | 2026/07/05 |

## 附录


Table: SRAM Bitcell 定义

\

Table: Vendor A Memory Compiler 定义



## Memory Compiler 工作内容
乙方根据甲方给出的规格定义及技术资料，完成Memory Compiler设计工作以及相应测试片的设计工作。

### Memory Compiler 规格定义
本项目共开发9套Memory Compiler，主要包含Single Port、Two Port、Dual Port、ROM等存储器编译器。详细信息如下表：

Table: Memory Compiler 定义


### Memory Compiler 功能特性定义
本项目Memory Compiler支持以下功能特性：

#### 支持按位写功能
存储器支持按位写功能，该功能选中时，存储器生成WEB的bus pin；存储器写入数据时，可以根据每一位独立进行写操作；若该功能未选中时，存储器不生成WEB，存储器写入数据时，所有位同时进行写操作。

> 除ROM不支持此功能外，其他所有存储器均支持此功能。

#### 支持电源管理模式
若选中电源管理模式，存储器除支持standby模式外，进一步支持Light Sleep、Deep Sleep、Shut Down三种电源管理模式。
Light Sleep模式支持较短的时间从使能状态恢复为Standby模式，并产生低于Standby模式的漏电流；
Deep Sleep模式支持较长的时间从使能状态回复为Standby模式，并产生低于Light Sleep模式的漏电流；
Shut Down模式支持最长的时间从使能状态恢复为Standby模式，并产生最小的漏电流。

> ROM仅支持light sleep和Shut Down外，其他存储器均支持三种电源管理模式。

#### 支持存储器使能门控功能
若存储器选中该功能时，存储器的地址、数据等信号收到存储器使能信号CEB的控制，会要求存储器使能信号需求更大的建立时间。同时避免地址、数据等信号跳变对存储器功耗的消耗；
若存储器未选中该能时，存储器的地址、数据等信号不受存储器使能信号CEB的控制，减小存储器使能信号的建立时间，但同时会增大地址、数据等信号跳变对存储器的功耗。

#### 支持双轨电源模式
存储器默认支持单轨电源模式，即存储器只有一个供电电源：VDD；若选中双轨电源模式，存储器有两个供电电源：VDD和VDDC，VDDC电源为存储器阵列的供电电源，VDD为存储器外围电路的供电电源，支持实现VDD和VDDC不同电位的工作模式。

> ROM不支持此功能，其他存储器均支持此功能。

#### 支持外围电源关断模式
存储器在选定双规电源模式和电源管理模式下，额外支持外围电源关断模式，支持用户关断存储器外围电路的供电电源，进一步节省功耗。

> ROM不支持此功能，其他存储器均支持此功能。

#### 支持读写余量控制
存储器支持读写余量控制功能，所有存储器默认使能此功能，存储器余量控制使能信号（EMCE）用于控制SRAM工作在默认模式或者可调试模式：
当EMCE=0时，SRAM工作在默认模式；
当EMCE=1时，SRAM可通过EMC[3:0]去调试读写余量，例如可以调试字线的脉宽，预充电关闭的时间以及位线选择信号打开的脉宽等，EMC[3:0]=0000时读写余量最大，读写操作速度最慢；EMC[3:0]=1111时读写余量最小，读写操作速度最快。

> 存储器根据端口类型以及存储器类型具有不同的Pin名字，详细请参考具体的用户手册。

#### 支持内部时钟旁路
当SRAM进行读写操作时，通过Self-Time Bypass使能信号，控制SRAM内部时钟的Recovery，也就是SRAM读写操作的结束时间。
当ETC=0时，Self-Time Bypass功能关闭，SRAM可进行正常的读写操作。
当ETC=1时，Self-Time Bypass功能开启，SRAM内部时钟的Recovery会在外部时钟的下降沿之后，这时SRAM内部的时序信号的Recovery，例如打开字线信号脉宽、关闭预充信号脉宽以及打开位线选择信号脉宽等，都会和外部时钟的高电平保持时间一样，这可以检测由于SRAM内部时钟脉宽不够导致的读写功能错误。

#### 支持读写辅助
存储器支持读辅助电路，用于规避由于静态噪声容限导致的存储单元故障；存储器支持写辅助电路，用于规避存储单元写容限不足导致的写错误。

> ROM不支持此功能，其他所有存储器均支持此功能。

#### 支持多种冗余配置
存储器支持不同的冗余配置：行冗余和列冗余。
行冗余通过内置的冗余行译码电路以及相应的冗余阵列替换功能失效的阵列行实现功能；
列冗余通过内置的冗余电路以及相应的冗余列替换实现列冗余功能，列冗余有两种模式可选：
`一组内置的列冗余替换待定的功能列。`
`两组内置的列冗余替换待定的功能列，存储器按照IO数分为高位组和低位组，高位组和低位组分别含有一组内置的列冗余分别替换自身组内代行的功能列，修复粒度更高。`

> ROM不支持此功能，其他所有存储器均支持列冗余配置。\
> 仅有SRAM支持行冗余配置，Register File和ROM不支持行冗余。

#### 支持ECC功能验证
存储器支持SRAM的ECC功能进行验证，ECC功能实现方式为Compiler提供可用于综合的实现ECC功能的RTL代码文件，ECC功能为SEC-DED（一位纠错两位检错）。

### Memory Compiler 容量范围定义

Table: High Density One Port Register File 容量范围定义

Table: Ultra High Density Two Port Register File 容量范围定义

Table: High Speed One Port Register File 容量范围定义

Table: High Density Two Port Register File 容量范围定义

Table: High Speed Single Port SRAM Compiler 容量范围定义

Table: High Density Dual Port SRAM Compiler 容量范围定义

Table: High Density Via ROM Compiler 容量范围定义

Table: Ultra High Density Single Port SRAM Compiler 容量范围定义

Table: High Speed Two Port Register File 容量范围定义


### Characterization Corner规格

Table: Characterization Corner 规格

> 以`TT0P72V0P9V25C`为例，0.72V为外围电路电源，0.9V为SRAM阵列电源。\
> \* 为功耗评估corner。\
> ROM compiler仅支持单轨电源corner（即VDD和VDDC为相同值）。

### Memory Compiler EDA View规格

Table: EDA View规格





## Memory Compiler 测试片规格定义

Memory Compiler测试片计划从2026年7月20日正式启动，最终交付时间约为2027年1月15日。测试片覆盖第一章所述9套Memory Compiler的验证需求。

### 测试片规格

测试片采用FT测试，使用ATE测试设备对封装后芯片进行测试。测试片规格信息如下：

Table: 测试片信息

测试片拟支持多种测试方案：

#### Memory功能测试
测试片支持对Memory实例进行读写操作功能测试。

#### 功耗测试
测试片支持对Memory实例进行静态功耗、睡眠模式、动态功耗进行测试。

#### 最高最低工作电压测试
测试片支持对SRAM多种工作电压进行测试，按照合理的电压步长进行最低和最高工作电压测试，测试需要得到读操作最低最高工作电压和写操作最低最高工作电压。

#### Retention测试
测试片通过常压读写操作，随后Standby模式下降低sram供电电压，随后升高到常压进行读操作。

#### HTOL测试
测试片支持SMarchCHKBvcd算法，并通过Mbist进行循环测试，用于提升HTOL测试效率，封装pad需要满足HTOL测试机台的要求。

#### MBIST算法高速测试
测试片支持使用SMarchCHKBvcd算法对Memory Instance进行额定最高工作频率进行高速测试。请留意双端口SRAM仅进行同步时钟测试，且需要留意同地址操作在算法激励中的规避。

#### 冗余功能测试
测试片支持对冗余功能的Memory实例进行功能验证，测试片支持解析后的冗余配置信息对Memory实例的冗余DFF链进行配置，从而实现冗余替换功能。

#### ECC功能测试
测试片支持对SRAM的ECC功能进行验证，使用提供的实现ECC功能的RTL代码进行综合，并支持外部向量置错场景下的一位纠错以及两位检错的功能验证。

#### 时序测试
测试片支持对Memory实例的关键信号的建立时间、保持时间以及数据读出时间进行测量。


### 测试片开发计划

Table: 测试片开发计划

### 封装测试计划

Table: 封装测试计划

