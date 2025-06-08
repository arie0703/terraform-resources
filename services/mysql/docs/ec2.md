# EC2にMySQLをホスティングする

初回はrootのパスワードを変更する必要がある

初期パスワードは以下コマンドで確認する

`cat /var/log/mysqld.log | grep password`

## 初回パスワード変更 + 新規ユーザ作成

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';

CREATE USER 'developer' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'developer'@'%' WITH GRANT OPTION;
```
