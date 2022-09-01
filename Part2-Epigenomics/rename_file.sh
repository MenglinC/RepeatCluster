for var in `ls *.bed`
do
        mv  $var  ${var%%_*.bed}.bed
done
#使用shell来批量的修改目录下的文件名
#这里运用到的一个主要的方法是shell的变量替换
