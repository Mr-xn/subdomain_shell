#!/usr/bin/env bash

#./subfinder -d mrxn.net -silent|sudo ./ksubdomain -verify -skip-wild -silent|./httpx -title -content-length -status-code -o mrxn.net.txt
# 一键调用subfinder+ksubdomain+httpx 强强联合从域名发现到域名验证到获取域名标题、状态码以及响应大小
# author : Mrxn
# github : https://github.com/Mr-xn
# 暂时只写了个单域名的，后面找时间补上从文件加载多域名脚本
# 其实加个判断调整下基本上就OK，欢迎各位师傅 pull
# 后期考虑加上 xray 的主动爬去来个简单的从域名到基本信息搜集的过程，可以做成定时任务
# tested on Mac

# 增加执行权限
chmod +x httpx subfinder ksubdomain

domain="$1"
# printf "${domain} \n"
# 创建域名文件夹
if [ ! -d ${domain} ];then
        mkdir ${domain}
fi

# 子域名文件
sub_file=${domain}'/'${domain}'_sub.txt'
# 验证结果文件
sub_file_ok=${domain}'/'${domain}'_sub_ok.txt'
# 各个域名对应标题、状态吗等信息文件
title_file=${domain}'/'${domain}'_title.txt'

# 各自命令定制
# 由于目前 httpx 输出文件如果不加 -no-color 参数，保存结果文件会包含颜色代码,故使用perl替换了一下后再保存

sub="./subfinder -d ${domain} -o ${sub_file} -silent"
ksubdomain="sudo ./ksubdomain v -b 20M -f ${sub_file} --od -o ${sub_file_ok}"
httpx="./httpx -t 30 -rl 60 -fr -maxr 3 -retries 3 -timeout 3 -ec -sc -cl -title -l ${sub_file_ok} -o tmp.txt &&cat tmp.txt|perl -pe 's/\e\[[0-9;]*m//g'|tee ${title_file}>>/dev/null 2>&1"
# -proxy http://127.0.0.1:8080 

# 如果子域名为空，删掉结果
del_null_sub(){
if [ -s ${title_file} ];then
    sleep 1
    printf "[+] 获取域名 <<${domain}>> 的子域名完成! \n[+] 保存在 <<${domain}>> 文件夹 \n"
    printf "=>>= 共 `wc -l ${sub_file}|awk '{print $1}'` 条子域名 \n"
    printf "=>>= 共 `wc -l ${sub_file_ok}|awk '{print $1}'` 条有效子域名 \n"
    printf "=>>= 共 `wc -l ${title_file}|awk '{print $1}'` 条可正常访问域名 \n"
    sudo chown -R `whoami` ${title_file}
else
    printf "[+] 没有获取到域名 <<${domain}>> 的任何有效域名！ \n"
    rm -rf ${domain}
    exit 1
fi
}

# delte tmp file
del_tmp(){
if [ -s tmp.txt ];then
    rm tmp.txt
fi
}

over(){
# 联合执行命令打印保存结果
if [ $? -eq 0 ];then
    del_null_sub
    printf "=>>= 结束时间:`date` \n"
else
    printf "[-] some error happened"
    rm -rf ${domain}
fi
del_tmp
}

# 脚本开始
printf "=>>= 作者:Mrxn \n"
printf "=>>= 脚本更新/反馈地址: \n"
printf "=>>= https://github.com/Mr-xn/subdomain_shell \n"
printf "=>>= ksubdomain需要网卡的 root 权限,请注意输入密码,或者使用 sudo 执行本脚本(推荐) \n"
printf "=>>= 开始时间:`date` \n"


if [ ${domain} ];then
    printf "=>>= 开始爬取 ${domain} 子域名...请稍等...\n"
    eval $sub
    sleep 1
    printf "=>>= 开始验证 ${domain} 子域名有效性...\n"
    eval $ksubdomain
    sleep 1
    printf "=>>= 开始获取 status_codes、content_length、title...\n"
    eval $httpx
    over
else
    printf "\n"
    printf "=!!= 脚本已经退出,请先输入查询的域名.\n"
    exit 1
fi

# End
