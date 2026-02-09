:: 彻底粉碎修复备份目录
rd /s /q "C:\Users\Arabid\AppData\Local\Temp\sgrepairbackup" 2>nul
:: 创建一个同名文件并剥夺所有权限，让搜狗无法创建该目录
echo. > "C:\Users\Arabid\AppData\Local\Temp\sgrepairbackup"
icacls "C:\Users\Arabid\AppData\Local\Temp\sgrepairbackup" /inheritance:r /deny Everyone:(F)