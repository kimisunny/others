# Arch Linux 安装简明流程

这是一篇为 **GPT/EFI 引导** 的电脑安装 Arch Linux（单系统）的自用中文简明流程。

> 双系统安装教程 https://github.com/JunkFood02/Arch-Linux-Installation-Guide

> Arch Linux官方中文安装指南 https://wiki.archlinuxcn.org/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97



## 预期投入

1. 至低要求 内存 2 GB | 硬盘 50 GB | 双核电脑
2. 容量4 GB及以上的可用且可格式化的U盘
3. 稳定可用的有线或无线网络
4. 空闲时间3小时以上

## 预期收益

1. 亲历Arch Linux安装过程
2. 稳定、纯净、可定制的Linux系统
3. 熟悉部分Linux工具及命令
4. 认识Arch Linux官方wiki


## 镜像下载
Arch Linux官方ISO下载地址 https://archlinux.org/download/

## 启动U盘
1. 工具[Rufus] https://rufus.ie/zh/
2. 使用 Rufus 将 Arch Linux 镜像装载到 U 盘，所有参数保持默认不修改即可


## BIOS 设置

不同品牌的电脑/主板进入 BIOS 设置的方法不一样，绝大部分是在开机界面 按 F2（或 Fn+F2），启动菜单是按下 Esc 或 F8，请自行搜索。


1. 关闭 `Secure Boot`，Arch Linux 安装程序无法使用 `Secure Boot` 启动，你可以在完成安装之后再启用此功能。
2. 某些品牌（如戴尔）的电脑可能不会在其他系统中默认开启网卡，需要在设置中启用  `Enable UEFI Network Stack`。
3. 调整 BIOS 默认的启动顺序（`Boot Sequence` / `Boot Order`），检查是否有装载有 Arch Linux 的 U 盘，将其顺序调整到第一位（你也可以在计算机启动时手动进入启动菜单选择要启动的系统），保存 BIOS 设置并退出。

   > 说明：如果在这里找不到你的 U 盘（设备名形如 `ARCH_202204` ），说明可能你的设备开启了 `Secure Boot` 导致 BIOS 无法找到系统入口，保存 BIOS 设置退出后重新进行这一步即可。



## 开始安装 Arch Linux

1. 完成了 BIOS 的设置后，重启计算机，我们应该进入到了 Arch Linux 的界面,如果没有可重启计算机按 Esc 键选择带 UEFI 标识的U盘进入
2. 选择第一项 [ Arch Linux install mdedium（x86_64，UEFI）]
3. 等待Arch Linux加载启动
4. 出现[root@archiso]字样，恭喜已进入`Zsh`命令行



## 连接网络

### 连接有线网络

不同型号的无线网卡的支持情况不同，若有条件推荐优先使用有线网网络进行连接，可以直接使用 USB 线将手机连接电脑使用手机的数据网络。

接入网线或手机进行有线网连接，并测试网络是否联通



### 连接无线网络

#### 事前故障排除

解除可能出现的软硬件 block


```shell
rfkill unblock all
```

列出当前网络设备

```shell
ip link
```

一般而言，无线网卡的名字默认为 `wlan0`，检查其状态，若为 `DOWN` 还需设置为 `UP`，*wlan0* 请替换成此处显示的网卡名

```
ip link set wlan0 up
```



执行以下命令

```
iwctl
```

会进入一个以 [iwd] 开头的命令行环境中，接着执行：

```
device list
```

会列出当前可用的所有网卡设备，一般而言，无线网卡的名字默认为 `wlan0`，接着执行下列命令进行无线网络的扫描：`wlan0` 请替换成此处显示的网卡名

```
station wlan0 scan
```

接着执行下列命令列出扫描到的网络：

```
station wlan0 get-networks
```

最后输入下列命令连接指定网络：`Wifi-SSID` 请切换成你想要连接的网络，输入密码回车即可连接成功。

```
station wlan0 connect Wifi-SSID
```

> 提示：单次或多次按下 `Tab` 可以补全或选择可能的选项，免去输入校对之苦

使用 `quit` 退出 `iwc`，测试网络是否联通


### 检查网络

> 无论使用何种方式连接的网络，都需要检测网络联通

使用 ip 命令查看网络，此命令会列出所有网络设备，并显示网络地址
```
ip addr
```

使用 ping 命令查看网络是否联通
```
ping www.baidu.com
```

> 使用 `Ctrl+C` 中止当前正在执行的命令

> 提示：可以使用方向键的上、下键来查看曾经执行过的指令的历史记录





## 设置系统时间

```
timedatectl set-ntp true
```

操作成功无提示





## 分区的格式化与挂载

> **Warning**
>
> 警告：除非你清楚你自己在做什么，否则请不要对硬盘分区表、以及除自己新建的分区之外的分区进行任何操作，并且请多次检查自己有没有输错命令，以防对其他分区的数据产生影响。
>
> 警告：硬盘相关操作可能造成数据遗失，在非确定的情况下，注意先行保存硬盘数据


### Fdisk
Fdisk 是基于命令行界面的分区表创建和编辑工具 ，详见 https://wiki.archlinuxcn.org/wiki/Fdisk


列出当前所有设备与分区

```
fdisk -l
```

选择进入即将安装 Arch Linux 的硬盘，本文默认使用`/dev/sda`（请以自己的设备情况为准，相关操作替换即可）

```
fdisk /dev/sda
```

创建新的分区表

> 警告：如果在存有数据的磁盘上创建新分区表，它将擦除磁盘上的所有数据
>

使用 `g`来新建一个GUID分区表 (GPT) 


### 新建 EFI 系统分区

如果你在一块 **新硬盘** 上安装 Arch Linux，则需要为其新建一个 EFI 系统分区

**如果你要在一块已经安装有 Windows 的硬盘上安装 Arch Linux，跳过这一步**


使用 `F` 列出当前的未分配空间

使用 `n` 在未分配空间新建分区，分区号与起始扇区默认即可，终止扇区输入预期数值，如 `+500M`（或 +1G），即给该新分区分配相应的磁盘空间

使用 `t`，默认分区号为1，将该分区标记为 `EFI System` 分区，如无意外应该是 `1`

使用 `L` 列出分区类型标号列表，可以查找需要的类型标号


### 新建数据分区

重复新建EFI系统分区的操作，若投入全部磁盘空间，终止扇区默认，分区标号为 23 [Linux root（x86_64）] 


`w` 保存并退出

使用 fdisk 查看操作结果，会列出以上操作相关的数据
```
fdisk -l /dev/sda
```


### 格式化分区

格式化EFI分区，执行成功会显示 `mkfs.fat` 版本与日期

```shell
mkfs.fat -F 32 /dev/sda1
```

格式化数据分区，执行成功会显示UUID及相关信息

```shell
mkfs.ext4 /dev/sda2
```


### 挂载分区

挂载数据分区
```shell
mount /dev/sda2 /mnt
```

挂载EFI系统分区
```shell
mount --mkdir /dev/sda1 /mnt/boot 
```

由于挂载操作成功无提示，需检查挂载是否成功

```
mount
```
> 若挂载成功，mount 命令末尾两行会显示`/dev/sda1`及`/dev/sda2`的信息，注意验证`type`


## 包管理器`pacman` 和 文本编辑器`Vim`

`pacman`是 Arch Linux默认包管理器，功能十分强大，且支持并行下载功能 https://wiki.archlinuxcn.org/wiki/Pacman
> `pacman -Syu` 包安装命令


运行命令以配置 `pacman` 所使用的镜像源，`Reflector` 会自动帮我们配置位于 China 的下载速度最快的镜像源

```
reflector --country China --sort rate --latest 5 --save /etc/pacman.d/mirrorlist
```

可能会报 `WARNING` 但无需理会



`Vim`是一个终端文本编辑器 https://wiki.archlinuxcn.org/wiki/Vim
> `vim filename` 进入编辑模式
> `i` 写入
> `Esc` 退出写入
> `wq` 退出`Vim` 


### 启用 `pacman` 并行下载功能
打开 `pacman` 设置，启用 `pacman` 的并行下载功能，加速下载，事半功倍。

```
vim /etc/pacman.conf
```

找到 `ParallelDownloads = 5` 这一行并取消其注释。



## 安装基本包及常规硬件

执行以下命令，安装 Arch Linux 所需要的基本包和常规硬件
```
# pacstrap -K /mnt base linux linux-firmware reflector vim
```

> 镜像initramfs构建时，你可能得到以下警告：
> 
> WARNING: Possibly missing firmware for module: wd719x
>
> WARNING: Possibly missing firmware for module: aic94xx
>
> WARNING: Possibly missing firmware for module: xhci_pci
>
> ......
>
> 说明：可忽略，也可安装相关包解除警告，如  `linux-firmware-qlogic`，详情查看 https://wiki.archlinuxcn.org/wiki/Mkinitcpio


## 生成 Fstab 文件

生成（Generate）自动挂载分区的 `fstab` 文件（即文件系统表 File System Table）

```
genfstab -L /mnt >> /mnt/etc/fstab
```

由于这步比较重要，所以我们需要输出生成的文件来检查是否正确，执行以下命令：

```
cat /mnt/etc/fstab
```

如果前面的挂载操作没有出错，应该输出且 **仅输出** 两条记录：（以你的磁盘分区情况为准）

- 根分区 `/` 被挂载到了此前建立的 **数据分区** `/dev/sda2`，分区的文件系统为 `ext4`


- 引导分区 `/boot` 被挂载到了 **硬盘已有的 EFI 系统分区** `/dev/sda1`，分区的文件系统为 `vfat`


如果 `fstab` 文件有任何错误，请先删除该文件

```
rm -rf /mnt/etc/fstab
```

检查前面的挂载操作有没有出错，`umount` 之后再重新挂载、生成。





## 新系统的必要配置

> 这里的配置流程虽然有些繁琐，但不会像前面的操作一样容易出错。

### Chroot

`Chroot` 意为 `Change root` ，相当于把操纵权交给我们新安装（或已经存在）的 `Linux` 系统，**执行了这步以后，我们的操作都相当于在磁盘上新装的系统中进行**。

执行如下命令：

```
arch-chroot /mnt
```

顺带一提，如果以后系统出现了问题，只要插入任意一个安装有 Arch Linux 镜像的 U 盘并启动，将我们的系统根分区挂载到 `/mnt` 下、EFI 系统分区挂载到 `/mnt/boot` 下，再通过这条命令就可以进入我们的系统进行修复操作。~~（用 Arch 的人身边都应该常备一个急救 U 盘）~~



## 安装必要软件包

> 此时已进入新安装的Arch Linux系统

重新启用`pacman` 的并行下载功能，找到 `ParallelDownloads = 5` 这一行并取消其注释，可以将 `5` 调整为你想要的数值。

调整镜像源
```
reflector --country China --sort rate --latest 5 --save /etc/pacman.d/mirrorlist
```

使用`pacman`安装必要软件包
```
pacman -S dialog wpa_supplicant dhcpcd ntfs-3g base-devel networkmanager netctl git
```

遇到需要选择的场合一路回车选择默认项即可。



### 设置时区、地区与语言信息

依次执行如下命令设置我们的时区为上海，并生成相关文件

```
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
```



执行如下命令，设置我们使用的语言选项

```
vim /etc/locale.gen
```

在文件中找到 `en_US.UTF-8 UTF-8`、`zh_CN.UTF-8 UTF-8`  这四行，去掉行首的 # 号，保存并退出。

执行如下命令，系统会生成我们需要的本地化文件

```
locale-gen
```



打开（不存在时会创建）`/etc/locale.conf`文件：

```
vim /etc/locale.conf
```

在文件的第一行加入以下内容

```
LANG=en_US.UTF-8
```

保存并退出



### 设置主机名

打开（不存在时会创建）`/etc/hostname` 文件：

```
vim /etc/hostname
```

在文件的第一行输入你自己设定的一个 `myhostname`，这将会是你的 **计算机名**，保存并退出。



打开（默认已存在且有两行英文，不存在时会创建）`/etc/hosts` 文件：

```
vim /etc/hosts
```

在文件末添加如下内容（将 `myhostname` 替换成你自己设定的主机名），保存并退出。

```
127.0.0.1	localhost
::1		localhost
127.0.1.1	myhostname.localdomain	myhostname
```



### 设置 Root 密码

`root` 账户是 `Linux` 系统中的最高权限账户，需要设置密码保护起来，以免无意间实施了破坏性的敏感操作。

```
passwd
```



### 新建用户与配置 sudo

> 关于这一步操作的说明，可以查看 [教程](https://www.viseator.com/2017/05/19/arch_setup/#%E6%96%B0%E5%BB%BA%E7%94%A8%E6%88%B7)

请自行替换 `username` 为你想要使用的用户名

```
useradd -m -G wheel username
```

```
passwd username
```

为了在普通用户下使用 root 操作，需要配置 sudo

```
pacman -S sudo
```

```
vim /etc/sudoers
```

找到 `# %wheel ALL=(ALL:ALL) ALL`，取消注释并保存退出。

> 若使用 `wq` 命令退出 `Vim` 时提示文件只读，可使用 `wq!` 命令强制保存退出



### 安装处理器微码

显然你应该根据你电脑的 CPU 型号选取一个包进行安装

```
pacman -S intel-ucode
pacman -S amd-ucode
```





## 配置系统引导

此处使用 `grub` 进行系统引导，先安装必要的包

```
pacman -S os-prober grub efibootmgr
```

启用 `os-prober`：编辑 grub 设置，取消注释下述设置项

```
vim /etc/default/grub
```

```
# GRUB_DISABLE_OS_PROBER=false
```

部署 `grub`

```
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
```

生成配置文件

```
grub-mkconfig -o /boot/grub/grub.cfg
```

检查文件末尾的 `menuenrtry` 是否有 Arch Linux 入口

```
vim /boot/grub/grub.cfg
```

> 以上均为命令行操作，注意代码错误，若有任何报错请查阅 Arch Wiki、教程或自行搜索





## 创建交换文件

交换文件可以在物理内存不足的时候将部分内存暂存到交换文件中，避免系统由于内存不足而完全停止工作。之前通常采用单独一个分区的方式作为交换分区，现在更推荐采用交换文件的方式，更便于我们的管理。分配一块空间用于交换文件，执行：

```
dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress
```

将 `8192` 换成需要的大小，单位 Mb，一般与计算机 RAM 大小一致即可。

更改权限，执行：

```
chmod 600 /swapfile
```

设置交换文件，执行：

```
mkswap /swapfile
```

启用交换文件，执行：

```
swapon /swapfile
```

最后我们需要编辑 `/etc/fstab` 为交换文件设置一个入口，使用 `Vim` 打开文件：

```
vim /etc/fstab
```

**注意编辑 `fstab` 文件的时候要格外注意不要修改之前的内容，直接在最后新起一行加入以下内容**：

```
/swapfile none swap defaults 0 0
```





## 安装图形界面

> 再次提醒，你应当开启 `pacman` 的并行下载功能
>
> 遇到需要选择的场合一路回车选择默认项即可



安装 Xorg 图形服务

```
pacman -S xorg
```

初次安装一般在 KDE 与 Gnome 之间选择



## 安装 KDE Plasma


精简安装

```
pacman -S plasma konsole dolphin
```

附加KDE软件包安装

```
pacman -S plasma kde-applications
```

安装桌面管理器 sddm

```
pacman -S sddm
```

设置 sddm 开机启动

```
systemctl enable sddm
```

> kde-applications是KDE桌面多达200多款软件的集合包，均可以独立安装，不建议全部安装 https://apps.kde.org/zh-cn/
> Linux 其他桌面环境请自行探索


### 网络服务

启用适用于桌面环境的网络服务 `NetworkManager`

```
systemctl disable netctl
systemctl enable NetworkManager
```

### 中文字体与中文输入法

> 防止切换中文后，显示中文乱码，提前安装中文字体和输入法
> 之后在系统语言设置内加入中文，安装中文字体与中文输入法后重启即可

```
pacman -Syu noto-fonts-cjk noto-fonts-emoji
```

可以使用 fcitx4 的搜狗输入法，或在 fcitx5 的拼音输入法中导入搜狗词库，参照 [fcitx](https://wiki.archlinux.org/title/fcitx#Chinese) 与 [fcitx5](https://wiki.archlinux.org/title/fcitx5#Chinese)

安装 fcitx5 及组件，在设置中添加输入法即可，具体参照 Arch Wiki
```
pacman -Syu fcitx5-im fcitx5-chinese-addons fcitx5-qt fcitx5-gtk
```

修改 `/etc/environment` 文件，在文件开头加入五行：

```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
INPUT_METHOD=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
```

可以解决一些软件无法调出 `fcitx` 的问题
> fcitx配置可以进入系统后调出网页复制操作

## 重启进入桌面环境

按`Ctrl` + `D` ，退出chroot，输入`reboot`并回车重启系统，进入图形界面


## 设置中文环境
1. 进入图形界面，登录`wheel`组用户
2. 进入`System Settings`
3. 进入`Regional Settings`
4. 点击第一行`Language`后的`Modify`按钮
5. 点击`Change Language`按钮
6. 在弹出框中下拉选择`简体中文`
7. 点击右下方`Apply`按钮
8. 在弹出提示中选择`Restart now`重启系统

> 可以编辑fcitx的环境文件后重启

## 快捷键
Arch Linux支持多种快捷键，详情见 https://wiki.archlinuxcn.org/wiki/%E5%BF%AB%E6%8D%B7%E9%94%AE

`Ctrl` + `F2` 启用图形界面
`Ctrl` + `F4` 启用tty4命令行

## AUR helper: yay

Arch Linux 除了官方源之外，还拥有广大社区用户维护的 **Arch 用户软件仓库**（Arch User Repository，简称 AUR）可供使用，极大丰富了 Arch Linux 的软件库，用户体验++

安装可以让我们便捷安装 AUR 包的 `yay`

```
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

> 软件源问题解决方案 https://zhuanlan.zhihu.com/p/439805266

1. go语言的软件安装源被屏蔽

换源
```
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```

临时生效
```
export GO111MODULE=on
export GOPROXY=https://goproxy.cn
```

永久生效
```
echo "export GO111MODULE=on" >> ~/.profile
echo "export GOPROXY=https://goproxy.cn" >> ~/.profile
source ~/.profile
```

> 绝大部分到此OK

2. github访问受限

修改hosts
```
sudo vim /etc/hosts
```

写入github hosts
```
# GitHub Host Start

185.199.108.154              github.githubassets.com
140.82.112.22                central.github.com
185.199.108.133              desktop.githubusercontent.com
185.199.108.153              assets-cdn.github.com
185.199.108.133              camo.githubusercontent.com
185.199.108.133              github.map.fastly.net
199.232.69.194               github.global.ssl.fastly.net
140.82.114.3                 gist.github.com
185.199.108.153              github.io
140.82.113.3                 github.com
140.82.112.5                 api.github.com
185.199.108.133              raw.githubusercontent.com
185.199.108.133              user-images.githubusercontent.com
185.199.108.133              favicons.githubusercontent.com
185.199.108.133              avatars5.githubusercontent.com
185.199.108.133              avatars4.githubusercontent.com
185.199.108.133              avatars3.githubusercontent.com
185.199.108.133              avatars2.githubusercontent.com
185.199.108.133              avatars1.githubusercontent.com
185.199.108.133              avatars0.githubusercontent.com
185.199.108.133              avatars.githubusercontent.com
140.82.112.10                codeload.github.com
52.217.207.1                 github-cloud.s3.amazonaws.com
52.216.78.4                  github-com.s3.amazonaws.com
52.217.194.169               github-production-release-asset-2e65be.s3.amazonaws.com
52.216.131.131               github-production-user-asset-6210df.s3.amazonaws.com
52.216.28.204                github-production-repository-file-5c1aeb.s3.amazonaws.com
185.199.108.153              githubstatus.com
64.71.144.202                github.community
185.199.108.133              media.githubusercontent.com

# Please Star : https://github.com/ineo6/hosts
# Mirror Repo : https://gitee.com/ineo6/hosts
# Update at: 2021-12-01 08:39:41

# GitHub Host End
```

使更新的hosts立即生效
```
sudo systemctl restart nscd
```

## 官方wiki及显卡驱动

Arch Linux官方wiki 目录 https://wiki.archlinuxcn.org/wiki/%E7%9B%AE%E5%BD%95
图形相关 https://wiki.archlinuxcn.org/wiki/Category:%E5%9B%BE%E5%BD%A2
ATI https://wiki.archlinuxcn.org/wiki/ATI
