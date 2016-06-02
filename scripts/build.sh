rm -rf ../build
mkdir ../build
function build()
{
	for file in $1/*
	do
		if [ -d "$file" ]; then
				mkdir ../build/"$file"
				build "$file"
		fi	
	done
	for file in $1/*.lua
	do
		if [ -f "$file" ]; then
			./luajit -b "$file" ../build/"$file"
		fi
	done
}
for file in *
do
if [ -d "$file" ]; then
	if [ "$file" != "jit" ]; then
		mkdir ../build/"$file"
		build $file
	fi
fi
done	
for file in *.lua
do
	if [ -f "$file" ]; then
		./luajit -b "$file" ../build/"$file"
	fi
done


