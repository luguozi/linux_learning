 
1.制作好个人的yum源库
2.制作好.repo文件，方便wget进行软件的安装
3.不同的软件类型用不同的yum源库，然后用不同的.repo指向。


参考gitlab 的安装包都是在yum库里面，要安装gitlab服务器时，可以直接下载gitlab的yum库，然后再开始用yum安装。