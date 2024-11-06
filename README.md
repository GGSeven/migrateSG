# migrateSG
跨账号复制AWS安全组
## 将export_security_group_unix.sh上传到Cloudshell
执行export_security_group_unix.sh脚本生成security-group.json文件，并下载到本地
ps：记得更改export_security_group_unix.sh中'SGID'字段
![image](https://github.com/user-attachments/assets/b1914b13-4885-4c79-bd73-4e667ce8a3de)

## 上传下载的security-group.json和import_security_group_unix.sh文件到另一个AWS账号
将上传的两个文件放到同一目录，执行脚本即可生成相同的安全组
