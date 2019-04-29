##########################################################################################
#
# Magisk模块安装脚本
#
##########################################################################################
##########################################################################################
#
# 说明:
#
# 1. 将文件放入系统文件夹（删除placeholder文件）
# 2. 将模块的信息填入module.prop
# 3. 在此文件中配置和实现调用
# 4. 如果需要启动脚本，请将它们添加到common/post-fs-data.sh或common/service.sh
# 5. 将附加或修改的系统属性添加到common/system.prop
#
##########################################################################################

##########################################################################################
# 配置开关
##########################################################################################

# system 启用=true,关闭=false
SKIPMOUNT=true

# system.prop 启用=true,关闭=false
PROPFILE=true

# post-fs-data 启用=true,关闭=false
POSTFSDATA=true

# service.sh 启用=true,关闭=false
LATESTARTSERVICE=true

##########################################################################################
# 替换列表
##########################################################################################

# 列出要在系统中直接替换的所有目录
# 查看官方文档以获取有关您需要的更多信息

# 按以下格式构建列表
# 这是一个例子
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# 在这里构建自定义列表
REPLACE="
"

##########################################################################################
#
# 函数调用
#
# 安装框架将调用以下函数。
# 您无法修改update-binary，这是您可以自定义的唯一方法
# 安装时通过实现这些功能。
#
# 在运行回调时，安装框架将确保Magisk
# 内部busybox的路径是*PREPENDED*到PATH,因此,所有常用命令应存在。
# 此外,它还将确保正确安装/data, /system和/vendor.
#
##########################################################################################
##########################################################################################
#
# 安装框架将导出一些变量和函数。
# 您应该使用这些变量和函数进行安装。
# 
# !不要使用任何Magisk内部路径，因为它们不是公共API。
# !请勿在util_functions.sh中使用其他函数，因为它们不是公共API。
# !不保证非公共API可以保持版本之间的兼容性。
#
# 可用变量:
#
# MAGISK_VER (string): 当前安装的Magisk的版本字符串
# MAGISK_VER_CODE (int): 当前安装的Magisk的版本代码
# BOOTMODE (bool): 如果模块当前正在Magisk Manager中安装,则为true
# MODPATH (path): 应安装模块文件的路径
# TMPDIR (path): 临时存储文件的地方
# ZIPFILE (path): 安装模块文件zip
# ARCH (string): 设备的架构.值为arm,arm64,x86或x64
# IS64BIT (bool): 如果$ ARCH是arm64或x64,则为true
# API (int): 设备的API级别(Android版本)
#
# 可用功能:
#
# ui_print <msg>
#     打印 <msg> 到安装界面
#     避免使用 'echo' 因为它不会显示在自定义安装界面
#
# 中止 <msg>
#     打印错误消息 <msg> 到安装界面和终止安装
#     避免使用 'exit' 因为它会跳过终止清理步骤
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# 如果需要启动脚本，请不要使用通用启动脚本 (post-fs-data.d/service.d)
# 只使用模块的脚本，因为它尊重模块状态 (remove/disable) and is
# 保证在未来的Magisk版本中保持相同的行为.
# 通过设置上面config部分中的标志启用引导脚本.
##########################################################################################

# 设置安装模块时要显示的内容

print_modname() {
ui_print "=========================="
ui_print "                                                                   "
ui_print "        Divine Turbo²®                     "
ui_print "          V4.1                                   "
ui_print "       "   
ui_print "=========================="
ui_print "-检测ID是否存在中，请稍后               "
ui_print "-已通过检测                                              "
ui_print "-编制时间：2019/4/29                    "
ui_print "-谢谢支持！                                "
ui_print "========================== "
}

# 在安装脚本中将模块文件复制/解压缩到 $MODPATH.

on_install() {
  # 以下是默认设置: 将 $ZIPFILE/system解压缩到 $MODPATH
  # 将逻辑扩展/更改为您想要的任何内容
  
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}

# 只有一些特殊文件需要特定权限
# 安装完成后，此功能将被调用
# 对于大多数情况，默认权限应该已经足够

set_permissions() {
  # 以下是默认规则,请勿删除
  set_perm_recursive $MODPATH 0 0 0755 0644

  # 以下是一些例子:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# 您可以添加更多功能来协助您的自定义脚本代码