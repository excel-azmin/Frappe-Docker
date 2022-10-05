**Install Frappe, ERPNext & Excel-ERPNext**

`cd Desktop`

`git clone https://github.com/excel-azmin/Frappe-Docker.git`

Copy example devcontainer config from `devcontainer-example` to `.devcontainer`

```
cp -R devcontainer-example .devcontainer
cp -R development/vscode-example development/.vscode
```

**Use VSCode Remote Containers extension**

Install Remote - Containers for VSCode [VS Code Remote Container Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

**After the extensions are installed, you can:**
* Open frappe_docker folder in VS Code. `cd frappe_docker`
* `code .`
* Launch the command, from Command Palette (Ctrl + Shift + P) `Remote-Containers: Reopen in Container`. You can also click in the bottom left corner to access the remote container menu.

**Setup Environment**
```
pip3.7 install virtualenv
python3.7 -m virtualenv MyEnv
source MyEnv/bin/activate
```

**Setup first bench**
```
bench init --skip-redis-config-generation --frappe-branch version-12 --python python3.7 frappe-bench
cd frappe-bench
```
**Setup hosts**

We need to tell bench to use the right containers instead of localhost. Run the following commands inside the container:

```
bench set-config -g db_host mariadb
bench set-config -g redis_cache redis://redis-cache:6379
bench set-config -g redis_queue redis://redis-queue:6379
bench set-config -g redis_socketio redis://redis-socketio:6379
```
For any reason the above commands fail, set the values in `common_site_config.json` manually.

```
{
  "db_host": "mariadb",
  "redis_cache": "redis://redis-cache:6379",
  "redis_queue": "redis://redis-queue:6379",
  "redis_socketio": "redis://redis-socketio:6379"
}
```
**Create a new site with bench**
```
bench new-site excel_erpnext.localhost --mariadb-root-password 123 --admin-password admin --no-mariadb-socket
```
**Enable Developer Mode**
```
bench --site excel_erpnext.localhost set-config developer_mode 1
```
**Clear Cache**
```
bench --site excel_erpnext.localhost clear-cache
```
**Install ERPNext Apps**
```
bench get-app --branch version-12 erpnext https://github.com/frappe/erpnext.git
bench --site excel_erpnext.localhost install-app erpnext
```
**Install Excel ERPNext Apps**
```
bench get-app --branch version-12 excel_erpnext https://gitlab.com/castlecraft/excel_erpnext.git
bench --site excel_erpnext.localhost install-app excel_erpnext
```
**Start Apps**
```
bench start
```
**Brows your localhost**
```
http://excel_erpnext.localhost:8000/
```

# Restore Database 

Download the `mariadb` database from [here](https://files-for-excel-bd.s3.ap-southeast-1.amazonaws.com/20220612_060135/20220612_060135-testerp_excelbd_com-database.sql.gz). After complete the download extract file & past on frappe-bench directory.

* Create new `terminal` in your VS Code
* Run this command to restore database.
```
bench --site excel_erpnext.localhost --force restore 20211024_150012-testerp_excelbd_com-database.sql.gz
```
* It will take some time to successfully restore database. 

**Brows your localhost**
```
http://excel_erpnext.localhost:8000/
``` 

**Login**
* Username : `shaid`
* Password : `Shaid@123`


