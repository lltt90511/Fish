function copyAssert()
{
	echo "copy $1 to $2"
	for file in $1/*
	do
	if [ -d "$file" ]; then
		cp -rf "$file" $2
	fi

	if [ -f "$file" ]; then
		cp "$file" $2
	fi
	done
	echo "end copy $1 to $2"
}
function encodeImageAndCopy()
{
 echo "encodeImage $1 $2 "
echo "$OS"

./imgEncode_win.exe <<EOF
		 $1
		 $2
EOF
	
}
echo "build script"
cd scripts
sh build.sh
cd ..
tmpdir=winPackTmp
outdir=proj.win32/Release.win32/res
echo "clean oldFile"
rm -rf $tmpdir
mkdir  $tmpdir
rm -rf $outdir/*
copyAssert build $tmpdir
copyAssert res $tmpdir
copyAssert unPackagedRes/music $tmpdir
copyAssert unPackagedRes/res $tmpdir
copyAssert sound $tmpdir
copyAssert $tmpdir $outdir
encodeImageAndCopy $tmpdir $outdir
rm -rf $outdir/release.lua
echo "scriptsVersion = $1" >$outdir/config.lua