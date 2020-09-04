#./subfinder -d $1 -silent|sudo ./ksubdomain -e 0 -verify -silent|./httpx -title -content-length -status-code
# 一键调用subfinder+ksubdomain+httpx 强强联合从域名发现到域名验证到获取域名标题、状态码以及响应大小
# author : Mrxn
# github : https://github.com/Mr-xn
# 暂时只写了个单域名的，后面找时间补上从文件加载多域名脚本
# 其实加个判断调整下基本上就OK，欢迎各位师傅 pull
# 后期考虑加上 xray 的主动爬去来个简单的从域名到基本信息搜集的过程，可以做成定时任务
# tested on Ubuntu 18.04

# 创建域名文件夹
if [ ! -d $1 ];then
        mkdir $1
    fi
# 子域名文件
sub_file=$1'/'$1'_sub.txt'
# 各个域名对应标题、状态吗等信息文件
title_file=$1'/'$1'_title.txt'

# 各自命令定制
# 由于目前 httpx 输出文件如果不加 -no-color 参数，保存结果文件会包含颜色代码
printf "请自行在使用这个脚本之前确定ksubdomain列出来的你正在使用的外网网卡，比如 0 1 2 3 自信修改命令中的 -e 参数后的值"
sub="./subfinder -nW -d $1 -o ${sub_file}"
httpx="./httpx -title -content-length -status-code -o tmp.txt &&cat tmp.txt|perl -pe 's/\e\[[0-9;]*m//g'|tee ${title_file}>>/dev/null 2>&1"
ksubdomain='sudo ./ksubdomain -e 0 -verify -silent'
res=$sub'|'$ksubdomain'|'$httpx

# 联合执行命令打印保存结果
eval $res
if [ $? -eq 0 ];then
    printf "[+] about $1's subdomain and  title info get done! saved in $1 folder\n"
else
    printf "[-] some error happened"
fi