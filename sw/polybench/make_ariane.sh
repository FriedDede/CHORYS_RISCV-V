make clean

names=("2mm" "3mm" "atax" "bicg" "doitgen" "durbin" "gemm" "gemver" "gesummv" "lu" "ludcmp" "mvt" "syr2k" "syrk" "trisolv" "trmm")
for name in "${names[@]}"
do
    for i in {0..7}
    do
    ./make_polybench.sh cva6 ${name} ${i}
    done
done